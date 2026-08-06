export const MAX_ROOM_PLAYERS = 10;

export class RoomState {
  constructor(capacity = MAX_ROOM_PLAYERS) {
    this.capacity = capacity;
    this.rooms = new Map();
    this.duelSessions = new Map();
  }

  join(roomId, player) {
    const room = this.rooms.get(roomId) ?? new Map();
    if (!room.has(player.id) && room.size >= this.capacity) {
      return { ok: false, code: "room_full", players: this.players(roomId) };
    }
    room.set(player.id, { ...player });
    this.rooms.set(roomId, room);
    return { ok: true, players: this.players(roomId) };
  }

  leave(roomId, playerId) {
    const room = this.rooms.get(roomId);
    if (!room) return [];
    room.delete(playerId);
    this._removePlayerDuels(roomId, playerId);
    if (room.size === 0) this.rooms.delete(roomId);
    return this.players(roomId);
  }

  updatePosition(roomId, playerId, payload) {
    const room = this.rooms.get(roomId);
    const player = room?.get(playerId);
    if (!player) return null;
    const x = Number(payload.x);
    const y = Number(payload.y);
    if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
    player.region = String(payload.region ?? player.region).slice(0, 48);
    player.x = Math.max(-1000, Math.min(25000, x));
    player.y = Math.max(-1000, Math.min(25000, y));
    player.direction = String(payload.direction ?? player.direction ?? "south").slice(0, 20);
    return { ...player };
  }

  players(roomId) {
    const room = this.rooms.get(roomId);
    return room ? [...room.values()].map((player) => ({ ...player })) : [];
  }

  challengeDuel(roomId, challengerId, targetId) {
    const room = this.rooms.get(roomId);
    if (!room?.has(challengerId) || !room.has(targetId)) return { ok: false, code: "duel_player_missing" };
    if (challengerId === targetId) return { ok: false, code: "duel_self_target" };
    if (this.activeDuelFor(roomId, challengerId) || this.activeDuelFor(roomId, targetId)) {
      return { ok: false, code: "duel_player_busy" };
    }
    const duel = {
      id: `duel_${roomId}_${challengerId}_${targetId}_${Date.now()}`,
      challengerId,
      targetId,
      status: "pending",
    };
    const sessions = this.duelSessions.get(roomId) ?? new Map();
    sessions.set(duel.id, duel);
    this.duelSessions.set(roomId, sessions);
    return { ok: true, duel: { ...duel } };
  }

  respondToDuel(roomId, targetId, duelId, accept) {
    const duel = this.duelSessions.get(roomId)?.get(duelId);
    if (!duel) return { ok: false, code: "duel_missing" };
    if (duel.targetId !== targetId) return { ok: false, code: "duel_not_target" };
    if (duel.status !== "pending") return { ok: false, code: "duel_not_pending" };
    if (!accept) {
      this.duelSessions.get(roomId)?.delete(duelId);
      return { ok: true, duel: { ...duel, status: "declined" } };
    }
    duel.status = "active";
    return { ok: true, duel: { ...duel } };
  }

  duelSessionsFor(roomId) {
    const sessions = this.duelSessions.get(roomId);
    return sessions ? [...sessions.values()].map((duel) => ({ ...duel })) : [];
  }

  activeDuelFor(roomId, playerId) {
    return this.duelSessionsFor(roomId).find((duel) =>
      (duel.status === "pending" || duel.status === "active") &&
      (duel.challengerId === playerId || duel.targetId === playerId)
    ) ?? null;
  }

  _removePlayerDuels(roomId, playerId) {
    const sessions = this.duelSessions.get(roomId);
    if (!sessions) return;
    for (const [duelId, duel] of sessions) {
      if (duel.challengerId === playerId || duel.targetId === playerId) sessions.delete(duelId);
    }
    if (sessions.size === 0) this.duelSessions.delete(roomId);
  }
}
