--Recette de Viande～肉料理のレシピ～
-- 效果：
-- 「新式魔厨」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「新式魔厨」仪式怪兽仪式召唤。这个效果把「新式魔厨的油封佛拉斯」仪式召唤的场合，可以再让以下效果适用。
-- ●对方场上的守备表示怪兽全部变成表侧攻击表示。
local s,id,o=GetID()
-- 注册卡片效果主函数
function s.initial_effect(c)
	-- 为卡片注册仪式召唤所需素材「新式魔厨的油封佛拉斯」的代码
	aux.AddCodeList(c,53618197)
	-- 设置仪式召唤条件，要求等级合计达到仪式怪兽等级以上，并指定召唤来源为手卡
	aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,false,s.extraop)
end
-- 筛选符合条件的「新式魔厨」系列怪兽
function s.filter(c,e,tp)
	return c:IsSetCard(0x196)
end
-- 定义仪式召唤成功后的额外处理函数
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc or not tc:IsCode(53618197) then return end
	-- 检索对方场上所有守备表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 若存在守备表示怪兽且玩家选择发动效果，则执行后续处理
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 将对方场上的守备表示怪兽全部变为表侧攻击表示
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
