--ガンバラナイト
-- 效果：
-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，可以把这张卡的表示形式变成守备表示。
function c24291651.initial_effect(c)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，可以把这张卡的表示形式变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24291651,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c24291651.poscon)
	e1:SetOperation(c24291651.posop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：持有该效果的卡必须处于攻击表示
function c24291651.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果处理：检查卡是否为表侧表示且与效果相关，若是则将其变为守备表示
function c24291651.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
