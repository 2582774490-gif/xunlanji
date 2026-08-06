export const MAX_ROOM_PLAYERS = 10;

export class RoomState {
  constructor(capacity = MAX_ROOM_PLAYERS) {
    this.capacity = capacity;
    this.rooms = new Map();
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
}
