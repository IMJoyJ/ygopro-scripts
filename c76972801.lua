--ガガガガード
-- 效果：
-- 自己场上有名字带有「我我我」的怪兽2只以上存在的场合才能发动。这个回合，自己场上的怪兽不会被战斗以及卡的效果破坏。
function c76972801.initial_effect(c)
	-- 自己场上有名字带有「我我我」的怪兽2只以上存在的场合才能发动。这个回合，自己场上的怪兽不会被战斗以及卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c76972801.condition)
	e1:SetOperation(c76972801.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且卡名含有「我我我」的怪兽
function c76972801.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x54)
end
-- 发动条件：自己场上存在2只以上的「我我我」怪兽
function c76972801.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否存在至少2张满足过滤条件的卡
	return Duel.IsExistingMatchingCard(c76972801.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果处理：赋予自己场上的怪兽这回合内不被战斗和效果破坏的耐性
function c76972801.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的怪兽不会被战斗以及卡的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 向玩家注册效果：自己场上的怪兽不会被战斗破坏，持续到回合结束
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	-- 向玩家注册效果：自己场上的怪兽（含里侧表示）不会被卡的效果破坏，持续到回合结束
	Duel.RegisterEffect(e2,tp)
end
