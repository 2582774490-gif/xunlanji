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
	this.tradeSessions = new Map();
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
	this._removePlayerTrades(roomId, playerId);
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
    return this._publicPlayer(player);
  }

  players(roomId) {
    const room = this.rooms.get(roomId);
    return room ? [...room.values()].map((player) => this._publicPlayer(player)) : [];
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

  // Development-only bridge: the client may seed its inventory once after
  // joining a room. From that point, offers and settlement use the room's
  // ledger rather than client-provided trade amounts. Production must replace
  // this bootstrap with authenticated account inventory snapshots.
  seedTradeLedger(roomId, playerId, payload) {
    const player = this.rooms.get(roomId)?.get(playerId);
    if (!player) return { ok: false, code: "trade_player_missing" };
    if (player.tradeLedgerInitialized) return { ok: false, code: "trade_ledger_already_seeded" };
    player.tradeLedger = this._sanitizeLedger(payload);
    player.tradeLedgerInitialized = true;
    return { ok: true, ledger: this._publicLedger(player.tradeLedger) };
  }

  tradeLedgerFor(roomId, playerId) {
    const player = this.rooms.get(roomId)?.get(playerId);
    if (!player?.tradeLedgerInitialized) return { ok: false, code: "trade_ledger_missing" };
    return { ok: true, ledger: this._publicLedger(player.tradeLedger) };
  }

  requestTrade(roomId, requesterId, targetId) {
    const room = this.rooms.get(roomId);
    if (!room?.has(requesterId) || !room.has(targetId)) return { ok: false, code: "trade_player_missing" };
    if (requesterId === targetId) return { ok: false, code: "trade_self_target" };
    if (!room.get(requesterId).tradeLedgerInitialized || !room.get(targetId).tradeLedgerInitialized) return { ok: false, code: "trade_ledger_missing" };
    if (this.activeTradeFor(roomId, requesterId) || this.activeTradeFor(roomId, targetId)) return { ok: false, code: "trade_player_busy" };
    const trade = {
      id: `trade_${roomId}_${requesterId}_${targetId}_${Date.now()}`,
      requesterId,
      targetId,
      status: "pending",
      offers: {
        [requesterId]: this._emptyOffer(),
        [targetId]: this._emptyOffer(),
      },
      revision: 1,
    };
    const sessions = this.tradeSessions.get(roomId) ?? new Map();
    sessions.set(trade.id, trade);
    this.tradeSessions.set(roomId, sessions);
    return { ok: true, trade: this._publicTrade(trade) };
  }

  respondToTrade(roomId, targetId, tradeId, accept) {
    const trade = this.tradeSessions.get(roomId)?.get(tradeId);
    if (!trade) return { ok: false, code: "trade_missing" };
    if (trade.targetId !== targetId) return { ok: false, code: "trade_not_target" };
    if (trade.status !== "pending") return { ok: false, code: "trade_not_pending" };
    if (!accept) {
      trade.status = "declined";
      trade.revision += 1;
      return { ok: true, trade: this._publicTrade(trade) };
    }
    trade.status = "active";
    trade.revision += 1;
    return { ok: true, trade: this._publicTrade(trade) };
  }

  setTradeOffer(roomId, playerId, tradeId, payload) {
    const trade = this.tradeSessions.get(roomId)?.get(tradeId);
    const validation = this._activeTrader(trade, playerId);
    if (!validation.ok) return validation;
    const ledger = this.rooms.get(roomId).get(playerId).tradeLedger;
    const offer = this._sanitizeOffer(payload);
    if (!this._ledgerContains(ledger, offer)) return { ok: false, code: "trade_insufficient_funds" };
    // A client never decides the upgrade state carried by an offer. The room
    // copies it from the seller's registered ledger, and only when every copy
    // of that named item is being transferred. This keeps the development
    // prototype safe even before equipment receives unique-instance ids.
    offer.equipment = this._equipmentForOffer(ledger, offer);
    trade.offers[playerId] = offer;
    trade.revision += 1;
    return { ok: true, trade: this._publicTrade(trade) };
  }

  lockTradeOffer(roomId, playerId, tradeId) {
    const trade = this.tradeSessions.get(roomId)?.get(tradeId);
    const validation = this._activeTrader(trade, playerId);
    if (!validation.ok) return validation;
    const ledger = this.rooms.get(roomId).get(playerId).tradeLedger;
    const offer = trade.offers[playerId];
    if (!this._ledgerContains(ledger, offer)) return { ok: false, code: "trade_insufficient_funds" };
    offer.locked = true;
    trade.revision += 1;
    const participants = [trade.requesterId, trade.targetId];
    if (!participants.every((id) => trade.offers[id].locked)) return { ok: true, trade: this._publicTrade(trade), settled: false };
    const settled = this._settleTrade(roomId, trade);
    if (!settled.ok) return settled;
    return { ok: true, trade: this._publicTrade(trade), settled: true, ledgers: settled.ledgers };
  }

  cancelTrade(roomId, playerId, tradeId) {
    const trade = this.tradeSessions.get(roomId)?.get(tradeId);
    if (!trade) return { ok: false, code: "trade_missing" };
    if (trade.requesterId !== playerId && trade.targetId !== playerId) return { ok: false, code: "trade_not_participant" };
    if (trade.status !== "pending" && trade.status !== "active") return { ok: false, code: "trade_not_active" };
    trade.status = "cancelled";
    trade.revision += 1;
    return { ok: true, trade: this._publicTrade(trade) };
  }

  activeTradeFor(roomId, playerId) {
    return this.tradeSessionsFor(roomId).find((trade) =>
      (trade.status === "pending" || trade.status === "active") &&
      (trade.requesterId === playerId || trade.targetId === playerId)
    ) ?? null;
  }

  tradeSessionsFor(roomId) {
    const sessions = this.tradeSessions.get(roomId);
    return sessions ? [...sessions.values()].map((trade) => this._publicTrade(trade)) : [];
  }

  tradeStateFor(roomId, playerId, tradeId) {
    const trade = this.tradeSessions.get(roomId)?.get(tradeId);
    if (!trade) return { ok: false, code: "trade_missing" };
    if (trade.requesterId !== playerId && trade.targetId !== playerId) return { ok: false, code: "trade_not_participant" };
    return { ok: true, trade: this._publicTrade(trade) };
  }

  _removePlayerDuels(roomId, playerId) {
    const sessions = this.duelSessions.get(roomId);
    if (!sessions) return;
    for (const [duelId, duel] of sessions) {
      if (duel.challengerId === playerId || duel.targetId === playerId) sessions.delete(duelId);
    }
    if (sessions.size === 0) this.duelSessions.delete(roomId);
  }

  _removePlayerTrades(roomId, playerId) {
    const sessions = this.tradeSessions.get(roomId);
    if (!sessions) return;
    for (const [tradeId, trade] of sessions) {
      if (trade.requesterId === playerId || trade.targetId === playerId) sessions.delete(tradeId);
    }
    if (sessions.size === 0) this.tradeSessions.delete(roomId);
  }

  _emptyOffer() {
    return { gold: 0, items: {}, equipment: {}, locked: false };
  }

  _sanitizeLedger(payload) {
    const gold = Math.max(0, Math.min(2_000_000, Math.floor(Number(payload?.gold) || 0)));
    const items = this._sanitizeItemCounts(payload?.items, 120);
    return { gold, items, equipment: this._sanitizeEquipment(payload?.equipment, items) };
  }

  _sanitizeOffer(payload) {
    const gold = Math.max(0, Math.min(2_000_000, Math.floor(Number(payload?.gold) || 0)));
    return { gold, items: this._sanitizeItemCounts(payload?.items, 12), equipment: {}, locked: false };
  }

  _sanitizeEquipment(rawEquipment, items) {
    const equipment = {};
    const source = rawEquipment && typeof rawEquipment === "object" ? rawEquipment : {};
    for (const [rawName, rawState] of Object.entries(source)) {
      const name = String(rawName).trim().slice(0, 48);
      if (!name || Number(items[name] ?? 0) <= 0 || !rawState || typeof rawState !== "object") continue;
      const level = Math.max(0, Math.min(12, Math.floor(Number(rawState.level) || 0)));
      if (level > 0) equipment[name] = { level };
    }
    return equipment;
  }

  _equipmentForOffer(ledger, offer) {
    const equipment = {};
    for (const [name, offeredCount] of Object.entries(offer.items)) {
      const sourceCount = Number(ledger.items[name] ?? 0);
      const state = ledger.equipment?.[name];
      if (state && sourceCount > 0 && Number(offeredCount) === sourceCount) {
        equipment[name] = structuredClone(state);
      }
    }
    return equipment;
  }

  _sanitizeItemCounts(rawItems, maxTotal) {
    const items = {};
    let total = 0;
    const source = rawItems && typeof rawItems === "object" ? rawItems : {};
    for (const [rawName, rawCount] of Object.entries(source)) {
      const name = String(rawName).trim().slice(0, 48);
      const count = Math.max(0, Math.min(maxTotal, Math.floor(Number(rawCount) || 0)));
      if (!name || count <= 0 || total >= maxTotal) continue;
      const accepted = Math.min(count, maxTotal - total);
      items[name] = accepted;
      total += accepted;
    }
    return items;
  }

  _ledgerContains(ledger, offer) {
    if (!ledger || ledger.gold < offer.gold) return false;
    return Object.entries(offer.items).every(([name, count]) => Number(ledger.items[name] ?? 0) >= count);
  }

  _settleTrade(roomId, trade) {
    const room = this.rooms.get(roomId);
    const first = room?.get(trade.requesterId);
    const second = room?.get(trade.targetId);
    if (!first || !second || !this._ledgerContains(first.tradeLedger, trade.offers[first.id]) || !this._ledgerContains(second.tradeLedger, trade.offers[second.id])) {
      return { ok: false, code: "trade_insufficient_funds" };
    }
    this._moveOffer(first.tradeLedger, second.tradeLedger, trade.offers[first.id]);
    this._moveOffer(second.tradeLedger, first.tradeLedger, trade.offers[second.id]);
    trade.status = "completed";
    trade.revision += 1;
    return { ok: true, ledgers: { [first.id]: this._publicLedger(first.tradeLedger), [second.id]: this._publicLedger(second.tradeLedger) } };
  }

  _moveOffer(from, to, offer) {
    from.gold -= offer.gold;
    to.gold += offer.gold;
    for (const [name, count] of Object.entries(offer.items)) {
      from.items[name] -= count;
      if (from.items[name] <= 0) delete from.items[name];
      to.items[name] = Number(to.items[name] ?? 0) + count;
      if (offer.equipment?.[name]) {
        delete from.equipment[name];
        to.equipment[name] = structuredClone(offer.equipment[name]);
      }
    }
  }

  _activeTrader(trade, playerId) {
    if (!trade) return { ok: false, code: "trade_missing" };
    if (trade.status !== "active") return { ok: false, code: "trade_not_active" };
    if (trade.requesterId !== playerId && trade.targetId !== playerId) return { ok: false, code: "trade_not_participant" };
    return { ok: true };
  }

  _publicLedger(ledger) {
    return { gold: ledger.gold, items: structuredClone(ledger.items), equipment: structuredClone(ledger.equipment ?? {}) };
  }

  _publicPlayer(player) {
    const result = {
      id: player.id,
      name: player.name,
      region: player.region,
      x: player.x,
      y: player.y,
      direction: player.direction,
    };
    if (player.gender) result.gender = player.gender;
    return result;
  }

  _publicTrade(trade) {
    return {
      id: trade.id, requesterId: trade.requesterId, targetId: trade.targetId,
      status: trade.status, offers: structuredClone(trade.offers), revision: trade.revision,
    };
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
