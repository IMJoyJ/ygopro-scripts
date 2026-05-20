--神風のバリア －エア・フォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部回到持有者手卡。
function c5650082.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c5650082.condition)
	e1:SetTarget(c5650082.target)
	e1:SetOperation(c5650082.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c5650082.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即对方怪兽攻击宣言时）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：处于攻击表示且能送回手卡的怪兽
function c5650082.filter(c)
	return c:IsAttackPos() and c:IsAbleToHand()
end
-- 定义效果发动时的目标确认与操作信息设置函数
function c5650082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只满足条件的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5650082.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足条件的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c5650082.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁处理的操作信息为将这些怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义效果处理（使怪兽回到手卡）函数
function c5650082.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取对方场上所有满足条件的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c5650082.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽因效果送回持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
