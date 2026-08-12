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
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c21648584.damop)
	c:RegisterEffect(e2)
end
-- 使自己场上「急袭猛禽」怪兽在战斗时不会被破坏
function c21648584.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己场上「急袭猛禽」怪兽在战斗时不会被破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c21648584.indtg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为「急袭猛禽」怪兽
function c21648584.indtg(e,c)
	return c:IsSetCard(0xba)
end
-- 过滤墓地中的「急袭猛禽」怪兽
function c21648584.cfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- 检查自己墓地是否存在「急袭猛禽」怪兽
function c21648584.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在「急袭猛禽」怪兽
	return Duel.IsExistingMatchingCard(c21648584.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 使自己受到的全部伤害变成0
function c21648584.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己受到的全部伤害变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
