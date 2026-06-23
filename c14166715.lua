--Recette de Viande～肉料理のレシピ～
-- 效果：
-- 「新式魔厨」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「新式魔厨」仪式怪兽仪式召唤。这个效果把「新式魔厨的油封佛拉斯」仪式召唤的场合，可以再让以下效果适用。
-- ●对方场上的守备表示怪兽全部变成表侧攻击表示。
local s,id,o=GetID()
-- 注册仪式魔法卡的仪式召唤程序和额外效果处理函数
function s.initial_effect(c)
	-- 记录该卡与「新式魔厨的油封佛拉斯」（卡号53618197）的关联
	aux.AddCodeList(c,53618197)
	-- 设置仪式召唤条件为等级合计达到仪式怪兽等级以上，并指定从手卡召唤，且包含额外效果处理函数
	aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,false,s.extraop)
end
-- 定义仪式召唤的怪兽必须为「新式魔厨」系列
function s.filter(c,e,tp)
	return c:IsSetCard(0x196)
end
-- 当仪式召唤成功且召唤的是「新式魔厨的油封佛拉斯」时，询问玩家是否将对方场上守备表示怪兽变为攻击表示
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc or not tc:IsCode(53618197) then return end
	-- 检索对方场上所有守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 若对方场上存在守备表示怪兽且玩家选择确认，则触发后续效果
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把对方怪兽全部变成攻击表示？"
		-- 中断当前效果处理，避免与后续效果同时处理
		Duel.BreakEffect()
		-- 将符合条件的对方怪兽全部变为表侧攻击表示
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
