--ワイト夫人
-- 效果：
-- 这张卡的卡名只要在墓地存在当作「白骨」使用。此外，只要这张卡在场上表侧表示存在，「白骨夫人」以外的场上的3星以下的不死族怪兽不会被战斗破坏，也不受魔法·陷阱卡的效果影响。
function c40991587.initial_effect(c)
	-- 使该卡在墓地时视为「白骨」卡名
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- 只要这张卡在场上表侧表示存在，「白骨夫人」以外的场上的3星以下的不死族怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c40991587.etarget)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，「白骨夫人」以外的场上的3星以下的不死族怪兽也不受魔法·陷阱卡的效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c40991587.etarget)
	e3:SetValue(c40991587.efilter)
	c:RegisterEffect(e3)
end
-- 目标怪兽必须不是「白骨夫人」且为不死族等级3以下
function c40991587.etarget(e,c)
	return not c:IsCode(40991587) and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(3)
end
-- 效果不适用于魔法卡和陷阱卡且不包括特定卡号的卡片
function c40991587.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not te:GetHandler():IsCode(4064256)
end
