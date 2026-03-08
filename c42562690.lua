--EMアメンボート
-- 效果：
-- ①：攻击表示的这张卡被选择作为攻击对象时才能发动。这张卡变成表侧守备表示，那次攻击无效。
function c42562690.initial_effect(c)
	-- ①：攻击表示的这张卡被选择作为攻击对象时才能发动。这张卡变成表侧守备表示，那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42562690,0))  --"攻击无效"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c42562690.condition)
	e1:SetTarget(c42562690.target)
	e1:SetOperation(c42562690.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡必须处于攻击表示
function c42562690.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果处理目标：将自身变为表侧守备表示
function c42562690.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：将自身变为表侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理流程：检查自身是否仍在场上，若在则变为表侧守备表示并无效攻击
function c42562690.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否与效果相关且成功变为表侧守备表示
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- 无效此次攻击
		Duel.NegateAttack()
	end
end
