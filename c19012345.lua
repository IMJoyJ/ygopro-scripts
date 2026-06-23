--灰塵王 アッシュ・ガッシュ
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，这张卡的等级上升1星（等级最多12星）。
function c19012345.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，这张卡的等级上升1星（等级最多12星）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19012345,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c19012345.condition)
	e1:SetOperation(c19012345.operation)
	c:RegisterEffect(e1)
end
-- 判断伤害是否由对方造成且自身等级低于12星
function c19012345.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():IsLevelBelow(11)
end
-- 将自身等级上升1星
function c19012345.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 等级上升
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
