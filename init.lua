-- Monies
-- currency:minegeld, currency:minegeld_5, currency:minegeld_10

local merch_table = {  -- Selling, Cost, Store Name, Node Name
{'default:pick_wood', 'currency:minegeld_5', 'Wooden Pickaxes', 'wood_pick'},
{'default:gold_lump', 'currency:minegeld_5', 'Gold Lumps', 'gold_lump'},
}

for i in ipairs (merch_table) do
	local selling = merch_table[i][1]
	local cost = merch_table[i][2]
	local sname = merch_table[i][3]
	local nname = merch_table[i][4]

minetest.register_node('autostore:'..nname, {
	description = sname,
	tiles = {'default_wood.png'},
	groups = {choppy=2,oddly_breakable_by_hand=2, attached_node=1},
	paramtype = 'light',
	paramtype2 = 'facedir',
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 8*4)
		inv:set_size("input", 1)
		inv:set_size("output", 1)
		meta:set_string('formspec',
			'size[8,6]'..
			'label[0,0;Selling:]'..
			'label[0,1;For:]'..
			'item_image_button[1,0;1,1;'..selling..';blah;]'..
			'item_image_button[1,1;1,1;'..cost..';blah;]'..
			'label[2.5,0;Pay here:]'..
			'label[2.5,1;Take your stuff:]'..
			'list[current_name;input;5,0;1,1;]'..
			'list[current_name;output;5,1;1,1;]'..
			'button[6,0;2,1;buy;Buy Now]'..
               		'list[current_player;main;0,2;8,4;]')
			meta:set_string('infotext', sname)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local out = inv:get_stack("output", 1)
		if fields['buy'] then
			local instack = inv:get_stack("input", 1)
			if instack:get_name() == cost
			and out:item_fits(selling) then
				instack:take_item()
				inv:set_stack("input",1,instack)
				inv:add_item('output',selling)
			end
		end
	end,
})

end
