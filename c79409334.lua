--暗黒ステゴ
-- 效果：
-- 这张卡被选择作为对方怪兽的攻击对象时，这张卡变成守备表示。
function c79409334.initial_effect(c)
	-- 这张卡被选择作为对方怪兽的攻击对象时，这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79409334,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c79409334.target)
	e1:SetOperation(c79409334.operation)
	c:RegisterEffect(e1)
end
-- 效果发动目标过滤与检测：在发动阶段确认自身是否处于攻击表示，并向系统宣告将要改变表示形式的操作信息。
function c79409334.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 向系统宣告当前连锁的处理信息为：将自身（1张卡）的表示形式进行改变。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理：检查自身是否仍与该效果相关联且处于表侧攻击表示，若是则将其改变为表侧守备表示。
function c79409334.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将自身改变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
