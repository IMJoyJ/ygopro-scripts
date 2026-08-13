--避雷針
-- 效果：
-- 对方使用了「雷击」的时候，破坏对方全部怪兽代替自己的怪兽。发动后这张卡破坏。
function c42364257.initial_effect(c)
	-- 对方使用了「雷击」的时候，破坏对方全部怪兽代替自己的怪兽。发动后这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c42364257.condition)
	e1:SetTarget(c42364257.target)
	e1:SetOperation(c42364257.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，判断是否满足发动条件：对方玩家发动了可被无效的「雷击」。
function c42364257.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件由四部分构成：连锁发动者为对方（rp==1-tp）、该连锁效果为魔法卡的发动（re:IsHasType(EFFECT_TYPE_ACTIVATE)）、该魔法卡是「雷击」（卡号12580477）、且该连锁效果可被无效（Duel.IsChainDisablable(ev)）。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(12580477) and Duel.IsChainDisablable(ev)
end
-- 定义效果发动时的目标/操作信息设置函数。检查对方场上是否有怪兽（若无则不能发动），并设置操作信息：将本次连锁的「雷击」效果标记为无效对象，将对方场上全部怪兽标记为破坏对象。
function c42364257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的全部怪兽（主要怪兽区与额外怪兽区），用于判断是否存在可被破坏的怪兽并作为操作信息中的破坏对象集合。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：本次效果包含“使效果无效”类别，对象为当前连锁发动的「雷击」（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：本次效果包含“破坏”类别，对象为对方场上全部怪兽（g），数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理函数。处理时先尝试无效本次连锁的「雷击」效果；若成功无效，则重新获取对方场上全部怪兽并全部破坏。
function c42364257.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateEffect(ev)无效当前连锁对应的「雷击」效果，若无效成功则进入后续破坏处理。
	if Duel.NegateEffect(ev) then
		-- 在效果处理阶段重新获取对方场上当前存在的全部怪兽，确保破坏的是处理时在场的怪兽。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		-- 以效果原因（REASON_EFFECT）破坏对方场上全部怪兽g，将其送去墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
