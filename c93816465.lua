--ゼロ・ガードナー
-- 效果：
-- 把这张卡解放发动。这个回合自己怪兽不会被战斗破坏，和对方怪兽的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
function c93816465.initial_effect(c)
	-- 把这张卡解放发动。这个回合自己怪兽不会被战斗破坏，和对方怪兽的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93816465,0))  --"战斗伤害免疫"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c93816465.cost)
	e1:SetOperation(c93816465.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否可以解放，并执行解放自身作为发动代价
function c93816465.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 在全局注册本回合内自己怪兽不会被战斗破坏以及对自己的战斗伤害变成0的效果
function c93816465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 和对方怪兽的战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册本回合内对自己的战斗伤害变成0的效果
	Duel.RegisterEffect(e1,tp)
	-- 这个回合自己怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	-- 向玩家注册本回合内自己怪兽不会被战斗破坏的效果
	Duel.RegisterEffect(e2,tp)
end
