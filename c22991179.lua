--無視加護
-- 效果：
-- 对方怪兽的攻击宣言时，可以把自己墓地存在的1只昆虫族怪兽从游戏中除外，那次攻击无效。
function c22991179.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，可以把自己墓地存在的1只昆虫族怪兽从游戏中除外，那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22991179,0))  --"攻击无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c22991179.condition)
	e2:SetCost(c22991179.cost)
	e2:SetOperation(c22991179.activate)
	c:RegisterEffect(e2)
end
-- 设置效果发动条件：仅当对方的攻击宣言时（当前回合玩家并非效果控制者）才允许发动。
function c22991179.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为对方，用于限定“对方怪兽的攻击宣言时”。
	return tp~=Duel.GetTurnPlayer()
end
-- 筛选适合作为代价的卡：自己墓地中的昆虫族怪兽且可以作为代价除外。
function c22991179.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 支付发动代价：把自己墓地存在的1只昆虫族怪兽从游戏中除外。
function c22991179.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定代价是否满足：自己墓地是否存在至少1张符合条件的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c22991179.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张符合条件的昆虫族怪兽。
	local g=Duel.SelectMatchingCard(tp,c22991179.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的昆虫族怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：使那次攻击无效。
function c22991179.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前正在进行的对方怪兽的攻击。
	Duel.NegateAttack()
end
