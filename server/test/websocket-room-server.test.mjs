import assert from "node:assert/strict";
import { randomBytes } from "node:crypto";
import { spawn } from "node:child_process";
import net from "node:net";
import test from "node:test";

function clientFrame(payload) {
  const body = Buffer.from(JSON.stringify(payload));
  assert.ok(body.length <= 0xffff, "test client messages must fit the supported websocket frame size");
  const mask = randomBytes(4);
  const encoded = Buffer.alloc(body.length);
  for (let index = 0; index < body.length; index += 1) encoded[index] = body[index] ^ mask[index % 4];
  const header = body.length < 126
    ? Buffer.from([0x81, 0x80 | body.length])
    : Buffer.from([0x81, 0xfe, (body.length >>> 8) & 0xff, body.length & 0xff]);
  return Buffer.concat([header, mask, encoded]);
}

class LocalWebSocketClient {
  constructor(port) {
    this.port = port;
    this.socket = null;
    this.buffer = Buffer.alloc(0);
    this.messages = [];
    this.waiters = [];
    this.handshakeDone = false;
  }

  async connect() {
    await new Promise((resolve, reject) => {
      this.socket = net.createConnection({ host: "127.0.0.1", port: this.port });
      this.socket.once("error", reject);
      this.socket.once("connect", () => {
        this.socket.on("data", (chunk) => this._read(chunk));
        this.socket.write([
          "GET / HTTP/1.1",
          "Host: 127.0.0.1",
          "Upgrade: websocket",
          "Connection: Upgrade",
          `Sec-WebSocket-Key: ${randomBytes(16).toString("base64")}`,
          "Sec-WebSocket-Version: 13",
          "",
          "",
        ].join("\r\n"));
      });
      this._resolveHandshake = resolve;
      this._rejectHandshake = reject;
    });
  }

  send(payload) {
    this.socket.write(clientFrame(payload));
  }

  waitFor(type, predicate = () => true, timeoutMs = 1800) {
    const existing = this.messages.find((message) => message.type === type && predicate(message));
    if (existing) return Promise.resolve(existing);
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.waiters = this.waiters.filter((waiter) => waiter.resolve !== resolve);
        reject(new Error(`timed out waiting for ${type}`));
      }, timeoutMs);
      this.waiters.push({ type, predicate, resolve: (message) => {
        clearTimeout(timer);
        resolve(message);
      }});
    });
  }

  close() {
    this.socket?.end();
  }

  _read(chunk) {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    if (!this.handshakeDone) {
      const end = this.buffer.indexOf("\r\n\r\n");
      if (end < 0) return;
      const response = this.buffer.subarray(0, end).toString("utf8");
      this.buffer = this.buffer.subarray(end + 4);
      if (!response.startsWith("HTTP/1.1 101")) {
        this._rejectHandshake?.(new Error(`websocket handshake failed: ${response}`));
        return;
      }
      this.handshakeDone = true;
      this._resolveHandshake?.();
    }
    while (this.buffer.length >= 2) {
      let length = this.buffer[1] & 0x7f;
      let offset = 2;
      if (length === 126) {
        if (this.buffer.length < 4) return;
        length = this.buffer.readUInt16BE(2);
        offset = 4;
      }
      if (this.buffer.length < offset + length) return;
      const opcode = this.buffer[0] & 0x0f;
      const body = this.buffer.subarray(offset, offset + length);
      this.buffer = this.buffer.subarray(offset + length);
      if (opcode !== 0x1) continue;
      const message = JSON.parse(body.toString("utf8"));
      this.messages.push(message);
      for (const waiter of [...this.waiters]) {
        if (message.type !== waiter.type || !waiter.predicate(message)) continue;
        this.waiters.splice(this.waiters.indexOf(waiter), 1);
        waiter.resolve(message);
      }
    }
  }
}

async function startRoomServer(port) {
  const server = spawn(process.execPath, ["src/websocket-room-server.mjs"], {
    cwd: new URL("..", import.meta.url),
    env: { ...process.env, XUNLAN_SESSION_PORT: String(port) },
    stdio: ["ignore", "pipe", "pipe"],
  });
  let output = "";
  server.stdout.on("data", (chunk) => { output += chunk.toString("utf8"); });
  server.stderr.on("data", (chunk) => { output += chunk.toString("utf8"); });
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`room server did not start: ${output}`)), 1800);
    server.stdout.on("data", () => {
      if (!output.includes("ws://127.0.0.1")) return;
      clearTimeout(timer);
      resolve();
    });
    server.once("exit", (code) => {
      clearTimeout(timer);
      reject(new Error(`room server exited early (${code}): ${output}`));
    });
  });
  return server;
}

test("websocket room relays presence, position and a two-player duel", { concurrency: false }, async (t) => {
  const port = 18080 + Math.floor(Math.random() * 800);
  const server = await startRoomServer(port);
  const first = new LocalWebSocketClient(port);
  const second = new LocalWebSocketClient(port);
  t.after(() => {
    first.close();
    second.close();
    server.kill();
  });

  const health = await fetch(`http://127.0.0.1:${port}/health`).then((response) => response.json());
  assert.deepEqual(health, { ok: true, capacity: 10, rooms: 0 });
  await first.connect();
  first.send({ type: "hello", room: "launch-1", name: "甲", gender: "male", region: "starter_village" });
  const welcomeA = await first.waitFor("welcome");
  await second.connect();
  second.send({ type: "hello", room: "launch-1", name: "乙", gender: "female", region: "starter_village" });
  const rosterA = await first.waitFor("roster", (message) => message.players.length === 2);
  const rosterB = await second.waitFor("roster", (message) => message.players.length === 2);
  const playerB = rosterA.players.find((player) => player.id !== welcomeA.peerId);
  assert.equal(playerB.name, "乙");
  assert.equal(rosterB.players.find((player) => player.id === welcomeA.peerId).name, "甲");

  first.send({ type: "position", region: "mist_border", x: 9000, y: 1800, direction: "east" });
  const position = await second.waitFor("position", (message) => message.player.id === welcomeA.peerId);
  assert.deepEqual(position.player, { id: welcomeA.peerId, name: "甲", gender: "male", region: "mist_border", x: 9000, y: 1800, direction: "east" });

  first.send({ type: "duel_challenge", targetId: playerB.id });
  const pending = await second.waitFor("duel_sessions", (message) => message.duels.length === 1 && message.duels[0].status === "pending");
  second.send({ type: "duel_response", duelId: pending.duels[0].id, accept: true });
  const active = await first.waitFor("duel_sessions", (message) => message.duels.length === 1 && message.duels[0].status === "active");
  assert.equal(active.duels[0].challengerId, welcomeA.peerId);
  assert.equal(active.duels[0].targetId, playerB.id);
});
