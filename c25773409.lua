--伝説の柔術家
-- 效果：
-- 与守备表示的这张卡进行战斗的怪兽在伤害步骤终了时弹回其持有者的卡组的最上面。
function c25773409.initial_effect(c)
	-- 创建一个诱发必发效果，用于在伤害步骤结束时触发，效果描述为“返回卡组”，分类为回卡组效果，条件为c25773409.condition，目标为c25773409.target，效果处理为c25773409.operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25773409,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c25773409.condition)
	e1:SetTarget(c25773409.target)
	e1:SetOperation(c25773409.operation)
	c:RegisterEffect(e1)
end
-- 与守备表示的这张卡进行战斗的怪兽在伤害步骤终了时弹回其持有者的卡组的最上面。
function c25773409.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果发动条件：卡片是否与战斗关联或被战斗破坏，且攻击目标为该卡，且该卡处于守备表示
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttackTarget()==e:GetHandler()
		and bit.band(e:GetHandler():GetBattlePosition(),POS_DEFENSE)~=0
end
-- 设置效果处理时的操作信息，确定将攻击怪兽送回卡组
function c25773409.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将攻击怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.GetAttacker(),1,0,0)
end
-- 效果处理函数，获取攻击怪兽并将其送回卡组顶端
function c25773409.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 将攻击怪兽以效果原因送回其持有者卡组顶端
	Duel.SendtoDeck(a,nil,SEQ_DECKTOP,REASON_EFFECT)
end
