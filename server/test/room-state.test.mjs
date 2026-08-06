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
