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
-- 效果作用
function c22991179.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确保攻击方不是当前回合玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 效果作用
function c22991179.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- 效果作用
function c22991179.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在满足条件的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22991179.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c22991179.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果作用
function c22991179.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
end
