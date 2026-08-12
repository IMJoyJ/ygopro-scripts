--ファイヤー・ウォール
-- 效果：
-- 对方直接攻击宣言时，可以把自己墓地存在的1只炎族怪兽从游戏中除外，使那只怪兽的攻击无效。每次自己的准备阶段支付500基本分。若没有支付，这张卡破坏。
function c94804055.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方直接攻击宣言时，可以把自己墓地存在的1只炎族怪兽从游戏中除外，使那只怪兽的攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94804055,0))  --"攻击无效"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c94804055.condition)
	e2:SetCost(c94804055.cost)
	e2:SetOperation(c94804055.operation)
	c:RegisterEffect(e2)
	-- 每次自己的准备阶段支付500基本分。若没有支付，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c94804055.mtcon)
	e3:SetOperation(c94804055.mtop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可以作为代价除外的炎族怪兽
function c94804055.cfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToRemoveAsCost()
end
-- 攻击无效效果的处理函数
function c94804055.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使该次攻击无效
	Duel.NegateAttack()
end
-- 攻击无效效果的发动条件函数
function c94804055.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方怪兽发动的直接攻击，且此卡不在同一连锁中
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
-- 攻击无效效果的发动代价函数
function c94804055.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己墓地是否存在至少1只可以除外的炎族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94804055.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送提示信息，要求玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的炎族怪兽
	local g=Duel.SelectMatchingCard(tp,c94804055.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 维持代价效果的触发条件函数
function c94804055.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 维持代价效果的处理函数
function c94804055.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分，并询问玩家是否选择支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(94804055,2)) then  --"是否要支付500基本分维持「火焰壁」？"
		-- 让玩家支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 因未支付维持代价而将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
