--融合死円舞曲
-- 效果：
-- ①：以自己场上1只「魔玩具」融合怪兽和对方场上1只融合怪兽为对象才能发动。作为对象的怪兽以外的场上的特殊召唤的怪兽全部破坏。那之后，被这个效果把怪兽破坏的玩家受到作为对象的怪兽的攻击力合计数值的伤害。
function c34449261.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只「魔玩具」融合怪兽和对方场上1只融合怪兽为对象才能发动。作为对象的怪兽以外的场上的特殊召唤的怪兽全部破坏。那之后，被这个效果把怪兽破坏的玩家受到作为对象的怪兽的攻击力合计数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34449261.target)
	e1:SetOperation(c34449261.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选自己场上满足条件的「魔玩具」融合怪兽作为对象
function c34449261.filter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
		-- 效果作用：检查对方场上是否存在满足条件的融合怪兽作为对象
		and Duel.IsExistingTarget(c34449261.filter2,tp,0,LOCATION_MZONE,1,nil,tp,c)
end
-- 效果作用：筛选对方场上满足条件的融合怪兽作为对象
function c34449261.filter2(c,tp,tc)
	local tg=Group.FromCards(c,tc)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
		-- 效果作用：检查场上是否存在满足条件的特殊召唤怪兽作为破坏对象
		and Duel.IsExistingMatchingCard(c34449261.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tg)
end
-- 效果作用：过滤满足条件的特殊召唤怪兽（不是对象怪兽）
function c34449261.desfilter(c,tg)
	return not tg:IsContains(c) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果作用：设置连锁处理的目标怪兽并计算破坏数量和伤害值
function c34449261.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：检查是否满足发动条件（自己场上存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c34449261.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 效果作用：选择自己场上的「魔玩具」融合怪兽作为对象
	local g1=Duel.SelectTarget(tp,c34449261.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 效果作用：选择对方场上的融合怪兽作为对象
	local g2=Duel.SelectTarget(tp,c34449261.filter2,tp,0,LOCATION_MZONE,1,1,nil,tp,g1:GetFirst())
	g1:Merge(g2)
	-- 效果作用：获取所有满足破坏条件的怪兽组
	local g=Duel.GetMatchingGroup(c34449261.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,g1)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	local dam=g1:GetSum(Card.GetAttack)
	if g:FilterCount(Card.IsControler,nil,1-tp)==0 then
		-- 效果作用：设置给对象怪兽控制者造成伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,dam)
	elseif g:FilterCount(Card.IsControler,nil,tp)==0 then
		-- 效果作用：设置给对象怪兽控制者造成伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	else
		-- 效果作用：设置给双方玩家造成伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
	end
end
-- 效果作用：处理效果的发动，包括破坏和伤害
function c34449261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中被选中的对象卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local dam=tg:Filter(Card.IsFaceup,nil):GetSum(Card.GetAttack)
	-- 效果作用：获取所有满足破坏条件的怪兽组
	local g=Duel.GetMatchingGroup(c34449261.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tg)
	-- 效果作用：判断是否满足破坏和伤害的触发条件
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 and dam>0 then
		-- 效果作用：获取实际被破坏的怪兽组
		local dg=Duel.GetOperatedGroup()
		-- 效果作用：中断当前效果处理，使后续处理错开时点
		Duel.BreakEffect()
		-- 效果作用：若破坏的怪兽中存在己方控制的怪兽，则给己方造成伤害
		if dg:IsExists(Card.IsPreviousControler,1,nil,tp) then Duel.Damage(tp,dam,REASON_EFFECT,true) end
		-- 效果作用：若破坏的怪兽中存在对方控制的怪兽，则给对方造成伤害
		if dg:IsExists(Card.IsPreviousControler,1,nil,1-tp) then Duel.Damage(1-tp,dam,REASON_EFFECT,true) end
		-- 效果作用：完成伤害处理的时点触发
		Duel.RDComplete()
	end
end
