--御巫神楽
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「御巫」仪式怪兽仪式召唤。那之后，以下效果可以适用。
-- ●把最多有自己墓地的装备魔法卡种类数量的对方场上的卡破坏，给与对方破坏数量×1000伤害。
function c16310544.initial_effect(c)
	-- 注册一个仪式召唤程序，要求解放手卡或场上的怪兽使等级合计达到仪式怪兽等级以上，并从手卡仪式召唤符合条件的「御巫」怪兽
	local e1=aux.AddRitualProcGreater2(c,c16310544.filter,LOCATION_HAND,nil,nil,true,c16310544.extraop)
	e1:SetCountLimit(1,16310544+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
-- 筛选可以被仪式召唤的「御巫」仪式怪兽
function c16310544.filter(c,e,tp)
	return c:IsSetCard(0x18d)
end
-- 仪式召唤成功后执行的额外处理：计算自己墓地装备魔法卡种类数量，并选择是否破坏对方场上卡牌并造成伤害
function c16310544.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	-- 统计自己墓地中装备魔法卡的种类数量
	local ct=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_EQUIP):GetClassCount(Card.GetCode)
	-- 获取对方场上的所有卡牌作为可破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 判断是否有装备魔法卡种类且对方场上存在卡牌，若满足条件则询问玩家是否发动破坏效果
	if ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(16310544,0)) then  --"是否选对方场上的卡破坏？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,ct,nil)
		-- 显示选中的卡牌被破坏的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡牌从场上破坏
		local res=Duel.Destroy(sg,REASON_EFFECT)
		-- 对对方造成与破坏卡牌数量相等的伤害（每张1000点）
		Duel.Damage(1-tp,res*1000,REASON_EFFECT)
	end
end
