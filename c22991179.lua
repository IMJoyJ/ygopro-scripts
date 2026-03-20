--無視加護
-- 效果：
-- 对方怪兽的攻击宣言时，可以把自己墓地存在的1只昆虫族怪兽从游戏中除外，那次攻击无效。
function c22991179.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发即时效果，用于在对方怪兽攻击宣言时发动，将自身墓地一只昆虫族怪兽除外并无效该次攻击。
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
-- 效果发动条件：当前回合玩家不是攻击玩家。
function c22991179.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否与攻击玩家不同。
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤器函数，用于筛选墓地中的昆虫族且可作为除外代价的怪兽。
function c22991179.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的费用支付流程：检查是否有满足条件的怪兽，若有则选择并除外。
function c22991179.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在己方墓地中是否存在至少一张满足条件的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c22991179.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张满足条件的昆虫族怪兽从墓地除外。
	local g=Duel.SelectMatchingCard(tp,c22991179.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外作为发动效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时执行的操作：无效此次攻击。
function c22991179.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击无效。
	Duel.NegateAttack()
end
