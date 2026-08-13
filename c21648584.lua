--RR－レディネス
-- 效果：
-- ①：这个回合，自己场上的「急袭猛禽」怪兽不会被战斗破坏。
-- ②：自己墓地有「急袭猛禽」怪兽存在的场合把墓地的这张卡除外才能发动。这个回合，自己受到的全部伤害变成0。
function c21648584.initial_effect(c)
	-- ①：这个回合，自己场上的「急袭猛禽」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c21648584.activate)
	c:RegisterEffect(e1)
	-- ②：自己墓地有「急袭猛禽」怪兽存在的场合把墓地的这张卡除外才能发动。这个回合，自己受到的全部伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c21648584.damcon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c21648584.damop)
	c:RegisterEffect(e2)
end
-- ①效果发动时的处理函数：给己方场上的「急袭猛禽」怪兽赋予本回合内不会被战斗破坏的效果。
function c21648584.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合，自己场上的「急袭猛禽」怪兽不会被战斗破坏。②：自己墓地有「急袭猛禽」怪兽存在的场合把墓地的这张卡除外才能发动。这个回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c21648584.indtg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将上述免疫战斗破坏的效果注册到己方场上，持续到这个回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 免疫效果的适用对象筛选：卡名属于「急袭猛禽」系列的怪兽。
function c21648584.indtg(e,c)
	return c:IsSetCard(0xba)
end
-- ②效果条件用的过滤函数：检查是否为「急袭猛禽」系列的怪兽。
function c21648584.cfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件：自己墓地存在至少1只「急袭猛禽」怪兽。
function c21648584.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1只满足cfilter条件的「急袭猛禽」怪兽，作为②效果的发动条件。
	return Duel.IsExistingMatchingCard(c21648584.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- ②效果处理：使己方本回合受到的全部伤害变成0（战斗伤害与效果伤害均变为0），并设置效果伤害为0的标记。
function c21648584.damop(e,tp,eg,ep,ev,re,r,rp)
	-- ②（后半句）：这个回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“己方受到的伤害变成0”的效果注册到己方玩家，持续到这个回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“效果伤害无效化”的辅助效果注册到己方玩家，防止效果伤害重复触发，持续到这个回合结束。
	Duel.RegisterEffect(e2,tp)
end
