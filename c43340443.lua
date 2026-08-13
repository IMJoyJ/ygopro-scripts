--キックバック
-- 效果：
-- 怪兽的召唤·反转召唤无效，那只怪兽回到持有者手卡。
function c43340443.initial_effect(c)
	-- 怪兽的召唤·反转召唤无效，那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设置效果的发动条件：当前不存在正在处理的连锁（aux.NegateSummonCondition返回true），只能在召唤/反转召唤时点直接发动。
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetTarget(c43340443.target)
	e1:SetOperation(c43340443.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
end
-- 定义效果发动时的检查函数：chk==0时直接返回true，效果无需额外条件即可发动；同时登记操作信息，声明本效果将包含无效召唤和送回手卡两类处理，对象为正在召唤/反转召唤的怪兽eg。
function c43340443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将本次效果标记为“无效召唤”类别，对象为正在召唤/反转召唤的怪兽eg，计数为1，表示效果处理时将无效该怪兽的召唤。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,1,0,0)
	-- 登记操作信息：将本次效果标记为“送回手牌”类别，对象为同一只怪兽eg，计数为1，表示效果处理时将那只怪兽送回持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
-- 定义效果处理函数：实际执行本卡的效果，即无效那只怪兽的召唤，并将其送回持有者手卡。
function c43340443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发动无效召唤：使eg中的第一只怪兽（当前正在召唤/反转召唤的怪兽）的召唤无效。
	Duel.NegateSummon(eg:GetFirst())
	-- 将eg中的那只怪兽以效果原因（REASON_EFFECT）送回持有者手卡，完成“弹回手牌”。
	Duel.SendtoHand(eg,nil,REASON_EFFECT)
end
