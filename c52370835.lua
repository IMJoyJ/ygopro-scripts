--H・C ソード・シールド
-- 效果：
-- 自己场上有名字带有「英豪」的怪兽存在的场合，把这张卡从手卡送去墓地才能发动。这个回合，战斗发生的对自己的战斗伤害变成0，自己场上的名字带有「英豪」的怪兽不会被战斗破坏。这个效果在对方回合也能发动。
function c52370835.initial_effect(c)
	-- 效果原文内容：自己场上有名字带有「英豪」的怪兽存在的场合，把这张卡从手卡送去墓地才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52370835,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52370835.condition)
	e1:SetCost(c52370835.cost)
	e1:SetOperation(c52370835.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在表侧表示且名字带有「英豪」的怪兽
function c52370835.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 效果作用：判断是否满足发动条件，即自己场上有名字带有「英豪」的怪兽
function c52370835.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检索满足条件的卡片组
	return Duel.IsExistingMatchingCard(c52370835.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：设置发动代价，将此卡送去墓地
function c52370835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 效果作用：将目标怪兽特殊召唤
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果作用：发动时注册两个永续效果，一个使自己不会受到战斗伤害，另一个使自己场上的名字带有「英豪」的怪兽不会被战斗破坏
function c52370835.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这个回合，战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 效果原文内容：自己场上的名字带有「英豪」的怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c52370835.filter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 效果作用：将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 效果作用：过滤名字带有「英豪」的卡
function c52370835.filter(e,c)
	return c:IsSetCard(0x6f)
end
