--暗黒界の門
-- 效果：
-- ①：场上的恶魔族怪兽的攻击力·守备力上升300。
-- ②：1回合1次，从自己墓地把1只恶魔族怪兽除外才能发动。从手卡选1只恶魔族怪兽丢弃。那之后，自己从卡组抽1张。
function c33017655.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的恶魔族怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为所有场上恶魔族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FIEND))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，从自己墓地把1只恶魔族怪兽除外才能发动。从手卡选1只恶魔族怪兽丢弃。那之后，自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e4:SetDescription(aux.Stringid(33017655,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c33017655.cost)
	e4:SetTarget(c33017655.target)
	e4:SetOperation(c33017655.operation)
	c:RegisterEffect(e4)
end
-- 用于检测满足条件的墓地恶魔族怪兽，可被除外作为发动代价
function c33017655.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的墓地恶魔族怪兽并选择除外
function c33017655.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足发动条件：墓地存在至少1只恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33017655.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的墓地恶魔族怪兽除外
	local g=Duel.SelectMatchingCard(tp,c33017655.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查是否满足效果发动条件：手牌存在恶魔族怪兽且自己可以抽卡
function c33017655.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测手牌是否存在恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND,0,1,nil,RACE_FIEND)
		-- 检测玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理信息：丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置效果处理信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果发动后的操作：选择并丢弃1只恶魔族手牌，然后抽1张卡
function c33017655.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1只满足条件的手牌丢弃
	local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND,0,1,1,nil,RACE_FIEND)
	if g:GetCount()>0 then
		-- 将选中的手牌送入墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
