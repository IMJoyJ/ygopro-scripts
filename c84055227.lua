--ゲイシャドウ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，给这张卡放置1个魔力指示物。这张卡的攻击力上升这张卡放置的魔力指示物数量×200的数值。
function c84055227.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 这张卡战斗破坏对方怪兽的场合，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84055227,0))  --"放置指示物"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c84055227.condition)
	e1:SetOperation(c84055227.operation)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升这张卡放置的魔力指示物数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c84055227.attackup)
	c:RegisterEffect(e2)
end
-- 确认自身是否与本次战斗关联，且被战斗破坏的对方卡片是怪兽
function c84055227.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 给自身放置1个魔力指示物
function c84055227.operation(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 计算并返回自身放置的魔力指示物数量×200的数值
function c84055227.attackup(e,c)
	return c:GetCounter(0x1)*200
end
