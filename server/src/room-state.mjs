export const MAX_ROOM_PLAYERS = 10;
export const DUEL_ARENA_BOUNDS = Object.freeze({ left: 180, top: 220, right: 2880, bottom: 1720 });
const DUEL_START_POSITIONS = Object.freeze([Object.freeze({ x: 980, y: 970 }), Object.freeze({ x: 2080, y: 970 })]);
const DUEL_BASIC_COOLDOWN_MS = 520;
const DUEL_SKILL_COOLDOWN_MS = 1300;
const DUEL_BASIC_DAMAGE = 9;
const DUEL_SKILL_DAMAGE = 14;
const DUEL_ATTACK_RANGE = 250;

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
      arena: null,
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
    duel.arena = {
      fighters: {
        [duel.challengerId]: { ...DUEL_START_POSITIONS[0], hp: 100, direction: "east", lastBasicAt: 0, lastSkillAt: 0 },
        [duel.targetId]: { ...DUEL_START_POSITIONS[1], hp: 100, direction: "west", lastBasicAt: 0, lastSkillAt: 0 },
      },
      winnerId: "",
      revision: 1,
    };
    return { ok: true, duel: { ...duel } };
  }

  duelSessionsFor(roomId) {
    const sessions = this.duelSessions.get(roomId);
    return sessions ? [...sessions.values()].map((duel) => this._publicDuel(duel)) : [];
  }

  duelStateFor(roomId, playerId, duelId) {
    const duel = this.duelSessions.get(roomId)?.get(duelId);
    if (!duel) return { ok: false, code: "duel_missing" };
    if (duel.challengerId !== playerId && duel.targetId !== playerId) return { ok: false, code: "duel_not_participant" };
    if (!duel.arena) return { ok: false, code: "duel_not_active" };
    return { ok: true, state: this._publicArena(duel) };
  }

  moveDuelFighter(roomId, playerId, duelId, payload) {
    const duel = this.duelSessions.get(roomId)?.get(duelId);
    const validation = this._activeFighter(duel, playerId);
    if (!validation.ok) return validation;
    const x = Number(payload.x);
    const y = Number(payload.y);
    if (!Number.isFinite(x) || !Number.isFinite(y)) return { ok: false, code: "duel_bad_position" };
    const fighter = validation.fighter;
    fighter.x = Math.max(DUEL_ARENA_BOUNDS.left, Math.min(DUEL_ARENA_BOUNDS.right, x));
    fighter.y = Math.max(DUEL_ARENA_BOUNDS.top, Math.min(DUEL_ARENA_BOUNDS.bottom, y));
    fighter.direction = ["south", "south_west", "west", "north_west", "north", "north_east", "east", "south_east"].includes(payload.direction) ? payload.direction : fighter.direction;
    duel.arena.revision += 1;
    return { ok: true, state: this._publicArena(duel) };
  }

  attackDuelFighter(roomId, playerId, duelId, action, now = Date.now()) {
    const duel = this.duelSessions.get(roomId)?.get(duelId);
    const validation = this._activeFighter(duel, playerId);
    if (!validation.ok) return validation;
    const normalizedAction = action === "skill" ? "skill" : "basic";
    const attacker = validation.fighter;
    const targetId = duel.challengerId === playerId ? duel.targetId : duel.challengerId;
    const target = duel.arena.fighters[targetId];
    const cooldownKey = normalizedAction === "skill" ? "lastSkillAt" : "lastBasicAt";
    const cooldown = normalizedAction === "skill" ? DUEL_SKILL_COOLDOWN_MS : DUEL_BASIC_COOLDOWN_MS;
    if (now - attacker[cooldownKey] < cooldown) return { ok: false, code: "duel_action_cooldown" };
    attacker[cooldownKey] = now;
    const distance = Math.hypot(attacker.x - target.x, attacker.y - target.y);
    let result = "miss";
    if (distance <= DUEL_ATTACK_RANGE) {
      target.hp = Math.max(0, target.hp - (normalizedAction === "skill" ? DUEL_SKILL_DAMAGE : DUEL_BASIC_DAMAGE));
      result = "hit";
      if (target.hp === 0) {
        duel.status = "finished";
        duel.arena.winnerId = playerId;
        result = "victory";
      }
    }
    duel.arena.revision += 1;
    return { ok: true, result, state: this._publicArena(duel) };
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

  _activeFighter(duel, playerId) {
    if (!duel) return { ok: false, code: "duel_missing" };
    if (duel.status !== "active" || !duel.arena) return { ok: false, code: "duel_not_active" };
    const fighter = duel.arena.fighters[playerId];
    if (!fighter) return { ok: false, code: "duel_not_participant" };
    return { ok: true, fighter };
  }

  _publicDuel(duel) {
    return { id: duel.id, challengerId: duel.challengerId, targetId: duel.targetId, status: duel.status };
  }

  _publicArena(duel) {
    return {
      id: duel.id,
      status: duel.status,
      challengerId: duel.challengerId,
      targetId: duel.targetId,
      fighters: structuredClone(duel.arena.fighters),
      winnerId: duel.arena.winnerId,
      revision: duel.arena.revision,
    };
  }
}
