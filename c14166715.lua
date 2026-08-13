--Recette de Viande～肉料理のレシピ～
-- 效果：
-- 「新式魔厨」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「新式魔厨」仪式怪兽仪式召唤。这个效果把「新式魔厨的油封佛拉斯」仪式召唤的场合，可以再让以下效果适用。
-- ●对方场上的守备表示怪兽全部变成表侧攻击表示。
local s,id,o=GetID()
-- 初始化效果注册：记录这张卡上记载的『新式魔厨的油封佛拉斯』的卡名，并为这张卡注册仪式召唤『新式魔厨』仪式怪兽的效果，同时设定仪式召唤成功时适用的追加效果处理函数。
function s.initial_effect(c)
	-- 将卡号53618197（新式魔厨的油封佛拉斯）登记为这张卡规则上记载的卡名。
	aux.AddCodeList(c,53618197)
	-- 为这张仪式魔法注册仪式召唤效果：从手卡作为仪式召唤的素材区域，解放手卡·场上的怪兽直到等级合计达到仪式召唤怪兽等级以上，从手卡仪式召唤1只『新式魔厨』仪式怪兽（filter指定字段），并挂接额外的追加处理s.extraop。
	aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,false,s.extraop)
end
-- 仪式怪兽的过滤条件：选择卡名含有『新式魔厨』字段（SetCard 0x196）的怪兽作为仪式召唤对象。
function s.filter(c,e,tp)
	return c:IsSetCard(0x196)
end
-- 追加效果函数：只有仪式召唤的是『新式魔厨的油封佛拉斯』时才处理；若对方场上有守备表示怪兽且玩家选择适用，则中断当前效果串，将对方场上所有守备表示怪兽变为表侧攻击表示。
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc or not tc:IsCode(53618197) then return end
	-- 获取对方场上全部守备表示的怪兽作为可选对象。
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 判定存在守备表示怪兽，且让玩家选择是否把对方怪兽全部变为攻击表示。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把对方怪兽全部变成攻击表示？"
		-- 中断当前效果处理，使后续变更表示形式作为一个独立的效果处理阶段，避免与仪式召唤的处理冲突导致时点丢失。
		Duel.BreakEffect()
		-- 将符合条件的对方怪兽全部改变为表侧攻击表示。
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
