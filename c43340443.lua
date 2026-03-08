--キックバック
-- 效果：
-- 怪兽的召唤·反转召唤无效，那只怪兽回到持有者手卡。
function c43340443.initial_effect(c)
	-- 怪兽的召唤·反转召唤无效，那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 判断当前是否存在尚未结算的连锁环节
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetTarget(c43340443.target)
	e1:SetOperation(c43340443.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
end
-- 设置连锁处理时的OperationInfo，包含无效召唤和回手牌效果
function c43340443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，标记将要无效召唤效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,1,0,0)
	-- 设置连锁操作信息，标记将要将怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
end
-- 执行效果的处理函数，使怪兽召唤无效并送回手牌
function c43340443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤·反转召唤·特殊召唤的targets的召唤无效
	Duel.NegateSummon(eg:GetFirst())
	-- 以效果原因将目标怪兽送回持有者手牌
	Duel.SendtoHand(eg,nil,REASON_EFFECT)
end
