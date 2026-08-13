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
-- 效果发动条件：判断这张卡是否为攻击表示，对应“攻击表示的这张卡被选择作为攻击对象时才能发动”中的“攻击表示”条件。
function c42562690.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果发动时的目标处理：无选择对象，直接允许发动，并设置效果处理时将要进行的是变更表示形式的操作信息。
function c42562690.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：把本次效果处理分类标记为改变表示形式（CATEGORY_POSITION），对象为这张卡，数量为1，用于满足相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理：获取这张卡，若其仍与效果关联，则先将其变为表侧守备表示，若变更成功则再无效那次攻击。
function c42562690.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果关联，且能否被成功变为表侧守备表示；只有变更成功后才继续无效攻击。
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- 无效此次攻击，对应“那次攻击无效”。
		Duel.NegateAttack()
	end
end
