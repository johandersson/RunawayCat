local Zone = require("game.zone")

describe("Zone", function()
    it("selects the environment for a world position", function()
        local zones = Zone.defaults()

        local zone, index = Zone.at(zones, 5600)

        assert.equals("Stora staden", zone.name)
        assert.equals(3, index)
    end)

    it("provides a separate immutable-style default set", function()
        local first = Zone.defaults()
        local second = Zone.defaults()
        first[1].name = "changed"

        assert.equals("Hemkvarteren", second[1].name)
    end)
end)
