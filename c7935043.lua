--海竜神の加護
-- 效果：
-- 直到这个回合的结束阶段时，自己场上表侧表示存在的3星以下的水属性怪兽不会被战斗以及卡的效果破坏。
function c7935043.initial_effect(c)
	-- 直到这个回合的结束阶段时，自己场上表侧表示存在的3星以下的水属性怪兽不会被战斗以及卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c7935043.activate)
	c:RegisterEffect(e1)
end
-- 魔法卡发动时的效果处理：创建并注册使自身场上特定怪兽获得战斗与效果破坏抗性的全局效果
function c7935043.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 直到这个回合的结束阶段时，自己场上表侧表示存在的3星以下的水属性怪兽不会被战斗...破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTarget(c7935043.tg)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将不会被战斗破坏的效果注册给发动卡片的玩家
	Duel.RegisterEffect(e1,tp)
	-- 直到这个回合的结束阶段时，自己场上表侧表示存在的3星以下的水属性怪兽不会被...卡的效果破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTarget(c7935043.tg)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将不会被卡的效果破坏的效果注册给发动卡片的玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限定效果影响的对象为3星以下的水属性怪兽
function c7935043.tg(e,c)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
