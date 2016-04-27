autostore = {}
selling = 'default:dirt'
cost = 'default:dirt'

minetest.register_privilege("autostore", {
	description = "Place, Dig, and configure autostores.",
	give_to_singleplayer = false
})

formspec_base =
    'size[8,6;]'

formspec_inv =
    'list[current_player;main;0,2;8,4;]'

formspec_customer =
    formspec_base..
    'label[0,0;Selling:]'..
    'item_image_button[1.5,0;1,1;'..selling..';blah;]'..
    'label[0,1;For:]'..
    'item_image_button[1.5,1;1,1;'..cost..';blah;]'..
    'label[3,0;Pay:]'..
    'list[current_name;input;4.5,0;1,1;]'..
    'label[3,1;Take:]'..
	'list[current_name;output;4.5,1;1,1;]'..
    'button[6,0;2,1;buy;Buy Now]'..
    formspec_inv

formspec_owner =
    formspec_base..
    'label[0,0;Selling What:]'..
    'list[current_name;selling;2,0;1,1;]'..
    'label[0,1;For How Much:]'..
    'list[current_name;cost;2,1;1,1;]'..
    'field[5.3,0.4;3,1;sname;store name;a store]'..
    'button_exit[6,1;2,1;save;Save Store]'..
    formspec_inv

minetest.register_node('autostore:store', {
	description = 'store',
	tiles = {'default_wood.png'},
	groups = {choppy=2,oddly_breakable_by_hand=2, attached_node=1},
	paramtype = 'light',
	paramtype2 = 'facedir',
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
        meta:set_string('formspec', formspec_owner)
        meta:set_string('infotext', 'Unconfigured Store')
		inv:set_size('main', 8*4)
		inv:set_size("selling", 1)
		inv:set_size("cost", 1)
        inv:set_size("input", 1)
        inv:set_size("output", 1)
	end,

    after_place_node = function(pos, placer, itemstack, pointed_thing)
		if minetest.check_player_privs(placer:get_player_name(), {autostore = true}) then
		else
			minetest.remove_node(pos)
			return true
		end
	end,

    can_dig = function(pos, player)
    	if minetest.check_player_privs(player:get_player_name(), {autostore = true}) then
            return true
        else
            return false
        end
    end,

    on_rightclick = function(pos, node, clicker)
        local meta = minetest.get_meta(pos)
        if minetest.check_player_privs(clicker:get_player_name(), {autostore = true}) then
		    meta:set_string('formspec', formspec_owner)
        else
            meta:set_string('formspec', formspec_customer)
        end
    end,

	on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local out = inv:get_stack("output", 1)
        if fields ['save'] then
            meta:set_string('infotext', fields.sname)
            selling = fields.selling
            cost = fields.cost
        end
        if fields['buy'] then
			local instack = inv:get_stack("input", 1)
			if instack:get_name() == cost and out:item_fits(output) then
				instack:take_item()
				inv:set_stack("input",1,instack)
				inv:add_item("output",selling)
			end
        end
	end,
})
