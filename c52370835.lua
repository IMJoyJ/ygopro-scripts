--H・C ソード・シールド
-- 效果：
-- 自己场上有名字带有「英豪」的怪兽存在的场合，把这张卡从手卡送去墓地才能发动。这个回合，战斗发生的对自己的战斗伤害变成0，自己场上的名字带有「英豪」的怪兽不会被战斗破坏。这个效果在对方回合也能发动。
function c52370835.initial_effect(c)
	-- 自己场上有名字带有「英豪」的怪兽存在的场合，把这张卡从手卡送去墓地才能发动。这个回合，战斗发生的对自己的战斗伤害变成0，自己场上的名字带有「英豪」的怪兽不会被战斗破坏。这个效果在对方回合也能发动。
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
-- 定义筛选条件：卡片必须表侧表示且属于「英豪」系列（0x6f），用于判断场上是否存在符合发动条件的「英豪」怪兽。
function c52370835.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 发动条件判断：检查自己场上是否存在至少1只表侧表示且属于「英豪」系列的怪兽。
function c52370835.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在至少1张满足 cfilter 的「英豪」怪兽，存在则发动条件成立。
	return Duel.IsExistingMatchingCard(c52370835.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价函数：若为合法性检查（chk==0），返回手卡中的这张卡能否作为代价送去墓地；实际发动时将这张卡从手卡送去墓地作为代价。
function c52370835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：为本回合注册两个持续效果——自己的战斗伤害变为0，以及己方场上的「英豪」怪兽不会被战斗破坏，两者均在结束阶段重置。
function c52370835.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对自己的战斗伤害变为0”的效果注册给当前回合玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 自己场上的名字带有「英豪」的怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c52370835.filter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 将“己方场上的名字带有「英豪」的怪兽不会被战斗破坏”的效果注册到当前回合玩家的场上，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 定义受保护对象的筛选条件：被保护怪兽必须属于「英豪」系列（0x6f）。
function c52370835.filter(e,c)
	return c:IsSetCard(0x6f)
end
