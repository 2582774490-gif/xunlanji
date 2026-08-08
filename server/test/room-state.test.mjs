import test from "node:test";
import assert from "node:assert/strict";
import { RoomState } from "../src/room-state.mjs";

test("room caps the eleventh player and keeps a position authoritative", () => {
  const rooms = new RoomState(10);
  for (let index = 0; index < 10; index += 1) {
    assert.equal(rooms.join("launch-1", { id: `p${index}`, name: `修士${index}`, region: "starter_village", x: 0, y: 0 }).ok, true);
  }
  assert.equal(rooms.join("launch-1", { id: "p10", name: "第十一人" }).code, "room_full");
  const player = rooms.updatePosition("launch-1", "p0", { region: "mist_border", x: 9000, y: 1800, direction: "east" });
  assert.deepEqual(player, { id: "p0", name: "修士0", region: "mist_border", x: 9000, y: 1800, direction: "east" });
  assert.equal(rooms.leave("launch-1", "p0").length, 9);
});

test("server-authoritative duel sessions accept exactly two valid room players", () => {
  const rooms = new RoomState(10);
  rooms.join("launch-1", { id: "p1", name: "甲", region: "starter_village", x: 0, y: 0 });
  rooms.join("launch-1", { id: "p2", name: "乙", region: "starter_village", x: 0, y: 0 });
  rooms.join("launch-1", { id: "p3", name: "丙", region: "starter_village", x: 0, y: 0 });
  assert.equal(rooms.challengeDuel("launch-1", "p1", "p1").code, "duel_self_target");
  assert.equal(rooms.challengeDuel("launch-1", "p1", "missing").code, "duel_player_missing");
  const challenged = rooms.challengeDuel("launch-1", "p1", "p2");
  assert.equal(challenged.ok, true);
  assert.equal(challenged.duel.status, "pending");
  assert.equal(rooms.challengeDuel("launch-1", "p3", "p2").code, "duel_player_busy");
  assert.equal(rooms.respondToDuel("launch-1", "p3", challenged.duel.id, true).code, "duel_not_target");
  const accepted = rooms.respondToDuel("launch-1", "p2", challenged.duel.id, true);
  assert.equal(accepted.ok, true);
  assert.equal(accepted.duel.status, "active");
  assert.deepEqual(rooms.duelSessionsFor("launch-1"), [{ id: accepted.duel.id, challengerId: "p1", targetId: "p2", status: "active" }]);
  const initialArena = rooms.duelStateFor("launch-1", "p1", accepted.duel.id);
  assert.equal(initialArena.ok, true);
  assert.equal(initialArena.state.fighters.p1.hp, 100);
  assert.equal(rooms.moveDuelFighter("launch-1", "p1", accepted.duel.id, { x: 1320, y: 900, direction: "east" }).ok, true);
  assert.equal(rooms.moveDuelFighter("launch-1", "p2", accepted.duel.id, { x: 1440, y: 900, direction: "west" }).ok, true);
  const hit = rooms.attackDuelFighter("launch-1", "p1", accepted.duel.id, "basic", 2000);
  assert.equal(hit.ok, true);
  assert.equal(hit.result, "hit");
  assert.equal(hit.state.fighters.p2.hp, 91);
  assert.equal(rooms.attackDuelFighter("launch-1", "p1", accepted.duel.id, "basic", 2100).code, "duel_action_cooldown");
  const miss = rooms.attackDuelFighter("launch-1", "p2", accepted.duel.id, "skill", 4000);
  assert.equal(miss.ok, true);
  assert.equal(miss.result, "hit");
  rooms.leave("launch-1", "p2");
  assert.deepEqual(rooms.duelSessionsFor("launch-1"), []);
});
