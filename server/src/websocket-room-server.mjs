import { createHash, randomUUID } from "node:crypto";
import { createServer } from "node:http";
import { RoomState, MAX_ROOM_PLAYERS } from "./room-state.mjs";

const port = Number(process.env.XUNLAN_SESSION_PORT ?? 8080);
const rooms = new RoomState();
const peers = new Map();

function encodeFrame(payload) {
  const body = Buffer.from(JSON.stringify(payload));
  const header = body.length < 126
    ? Buffer.from([0x81, body.length])
    : Buffer.from([0x81, 126, (body.length >>> 8) & 0xff, body.length & 0xff]);
  return Buffer.concat([header, body]);
}

function send(peer, payload) {
  if (!peer.socket.destroyed) peer.socket.write(encodeFrame(payload));
}

function broadcast(roomId, payload, exceptId = "") {
  for (const peer of peers.values()) {
    if (peer.roomId === roomId && peer.id !== exceptId) send(peer, payload);
  }
}

function broadcastRoster(roomId) {
  broadcast(roomId, { type: "roster", players: rooms.players(roomId) });
}

function broadcastDuelSessions(roomId) {
  broadcast(roomId, { type: "duel_sessions", duels: rooms.duelSessionsFor(roomId) });
}

function sendDuelState(roomId, duelId) {
  const duel = rooms.duelSessionsFor(roomId).find((entry) => entry.id === duelId);
  if (!duel) return;
  for (const peer of peers.values()) {
    if (peer.roomId !== roomId) continue;
    const state = rooms.duelStateFor(roomId, peer.id, duelId);
    if (state.ok) send(peer, { type: "duel_state", duel: state.state });
  }
}

function sendTradeState(roomId, tradeId) {
  for (const peer of peers.values()) {
    if (peer.roomId !== roomId) continue;
    const state = rooms.tradeStateFor(roomId, peer.id, tradeId);
    if (state.ok) send(peer, { type: "trade_state", trade: state.trade });
  }
}

function sendTradeLedger(roomId, peerId) {
  const peer = peers.get(peerId);
  const result = rooms.tradeLedgerFor(roomId, peerId);
  if (peer && result.ok) send(peer, { type: "trade_ledger", ledger: result.ledger });
}

function closePeer(peer) {
  if (!peers.delete(peer.id)) return;
  const roomId = peer.roomId;
  if (roomId) {
    rooms.leave(roomId, peer.id);
    broadcastRoster(roomId);
    broadcastDuelSessions(roomId);
  }
}

function readFrames(peer, data) {
  peer.buffer = Buffer.concat([peer.buffer, data]);
  while (peer.buffer.length >= 2) {
    const first = peer.buffer[0];
    const second = peer.buffer[1];
    const masked = (second & 0x80) !== 0;
    let length = second & 0x7f;
    let offset = 2;
    if (length === 126) {
      if (peer.buffer.length < 4) return;
      length = peer.buffer.readUInt16BE(2);
      offset = 4;
    }
    if (length > 8192 || !masked || peer.buffer.length < offset + 4 + length) {
      peer.socket.destroy();
      return;
    }
    const mask = peer.buffer.subarray(offset, offset + 4);
    const encoded = peer.buffer.subarray(offset + 4, offset + 4 + length);
    const payload = Buffer.alloc(length);
    for (let index = 0; index < length; index += 1) payload[index] = encoded[index] ^ mask[index % 4];
    peer.buffer = peer.buffer.subarray(offset + 4 + length);
    const opcode = first & 0x0f;
    if (opcode === 0x8) {
      peer.socket.end();
      return;
    }
    if (opcode === 0x9) {
      peer.socket.write(Buffer.from([0x8a, 0x00]));
      continue;
    }
    if (opcode !== 0x1) continue;
    try {
      handleMessage(peer, JSON.parse(payload.toString("utf8")));
    } catch {
      send(peer, { type: "error", code: "bad_message" });
    }
  }
}

function handleMessage(peer, message) {
  if (message.type === "hello") {
    if (peer.roomId) return;
    const roomId = String(message.room ?? "launch-1").slice(0, 48);
    const player = {
      id: peer.id,
      name: String(message.name ?? "无名修士").slice(0, 16),
      gender: message.gender === "female" ? "female" : "male",
      region: String(message.region ?? "starter_village").slice(0, 48),
      x: 0,
      y: 0,
      direction: "south"
    };
    const joined = rooms.join(roomId, player);
    if (!joined.ok) {
      send(peer, { type: "error", code: "room_full", capacity: MAX_ROOM_PLAYERS });
      peer.socket.end();
      return;
    }
    peer.roomId = roomId;
    send(peer, { type: "welcome", peerId: peer.id, room: roomId, capacity: MAX_ROOM_PLAYERS });
    broadcastRoster(roomId);
    broadcastDuelSessions(roomId);
    return;
  }
  if (message.type === "position" && peer.roomId) {
    const player = rooms.updatePosition(peer.roomId, peer.id, message);
    if (player) broadcast(peer.roomId, { type: "position", player }, peer.id);
    return;
  }
	if (message.type === "trade_seed" && peer.roomId) {
		const result = rooms.seedTradeLedger(peer.roomId, peer.id, message);
		if (!result.ok) {
			send(peer, { type: "error", code: result.code });
			return;
		}
		send(peer, { type: "trade_ledger", ledger: result.ledger });
		return;
	}
	if (message.type === "trade_request" && peer.roomId) {
		const result = rooms.requestTrade(peer.roomId, peer.id, String(message.targetId ?? ""));
		if (!result.ok) {
			send(peer, { type: "error", code: result.code });
			return;
		}
		sendTradeState(peer.roomId, result.trade.id);
		return;
	}
	if (message.type === "trade_response" && peer.roomId) {
		const result = rooms.respondToTrade(peer.roomId, peer.id, String(message.tradeId ?? ""), message.accept === true);
		if (!result.ok) {
			send(peer, { type: "error", code: result.code });
			return;
		}
		sendTradeState(peer.roomId, result.trade.id);
		return;
	}
	if (message.type === "trade_offer" && peer.roomId) {
		const result = rooms.setTradeOffer(peer.roomId, peer.id, String(message.tradeId ?? ""), message);
		if (!result.ok) {
			send(peer, { type: "error", code: result.code });
			return;
		}
		sendTradeState(peer.roomId, result.trade.id);
		return;
	}
	if (message.type === "trade_lock" && peer.roomId) {
		const result = rooms.lockTradeOffer(peer.roomId, peer.id, String(message.tradeId ?? ""));
		if (!result.ok) {
			send(peer, { type: "error", code: result.code });
			return;
		}
		sendTradeState(peer.roomId, result.trade.id);
		if (result.settled) {
			sendTradeLedger(peer.roomId, result.trade.requesterId);
			sendTradeLedger(peer.roomId, result.trade.targetId);
		}
		return;
	}
	if (message.type === "trade_cancel" && peer.roomId) {
		const result = rooms.cancelTrade(peer.roomId, peer.id, String(message.tradeId ?? ""));
		if (!result.ok) {
			send(peer, { type: "error", code: result.code });
			return;
		}
		sendTradeState(peer.roomId, result.trade.id);
		return;
	}
  if (message.type === "duel_challenge" && peer.roomId) {
    const result = rooms.challengeDuel(peer.roomId, peer.id, String(message.targetId ?? ""));
    if (!result.ok) {
      send(peer, { type: "error", code: result.code });
      return;
    }
    broadcastDuelSessions(peer.roomId);
    return;
  }
  if (message.type === "duel_response" && peer.roomId) {
    const result = rooms.respondToDuel(peer.roomId, peer.id, String(message.duelId ?? ""), message.accept === true);
    if (!result.ok) {
      send(peer, { type: "error", code: result.code });
      return;
    }
    broadcastDuelSessions(peer.roomId);
    if (result.duel.status === "active") sendDuelState(peer.roomId, result.duel.id);
    return;
  }
  if (message.type === "duel_move" && peer.roomId) {
    const result = rooms.moveDuelFighter(peer.roomId, peer.id, String(message.duelId ?? ""), message);
    if (!result.ok) {
      send(peer, { type: "error", code: result.code });
      return;
    }
    sendDuelState(peer.roomId, String(message.duelId ?? ""));
    return;
  }
  if (message.type === "duel_action" && peer.roomId) {
    const result = rooms.attackDuelFighter(peer.roomId, peer.id, String(message.duelId ?? ""), String(message.action ?? "basic"));
    if (!result.ok) {
      send(peer, { type: "error", code: result.code });
      return;
    }
    sendDuelState(peer.roomId, String(message.duelId ?? ""));
    if (result.state.status === "finished") broadcastDuelSessions(peer.roomId);
  }
}

const server = createServer((request, response) => {
  if (request.url === "/health") {
    response.writeHead(200, { "content-type": "application/json" });
    response.end(JSON.stringify({ ok: true, capacity: MAX_ROOM_PLAYERS, rooms: rooms.rooms.size }));
    return;
  }
  response.writeHead(404);
  response.end();
});

server.on("upgrade", (request, socket) => {
  const key = request.headers["sec-websocket-key"];
  if (!key || request.headers["sec-websocket-version"] !== "13") {
    socket.destroy();
    return;
  }
  const accept = createHash("sha1").update(`${key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11`).digest("base64");
  socket.write(["HTTP/1.1 101 Switching Protocols", "Upgrade: websocket", "Connection: Upgrade", `Sec-WebSocket-Accept: ${accept}`, "", ""].join("\r\n"));
  const peer = { id: randomUUID(), socket, roomId: "", buffer: Buffer.alloc(0) };
  peers.set(peer.id, peer);
  socket.on("data", (data) => readFrames(peer, data));
  socket.on("close", () => closePeer(peer));
  socket.on("error", () => closePeer(peer));
});

server.listen(port, "127.0.0.1", () => {
  console.log(`寻岚记本机十人房服务器已运行：ws://127.0.0.1:${port}（每房最多 ${MAX_ROOM_PLAYERS} 人）`);
});
