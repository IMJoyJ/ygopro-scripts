--フォトン・パイレーツ
-- 效果：
-- 自己的主要阶段时把自己墓地1只名字带有「光子」的怪兽从游戏中除外才能发动。这张卡的攻击力直到结束阶段时上升1000。「光子海盗」的效果1回合可以使用最多2次。
function c36834155.initial_effect(c)
	-- 自己的主要阶段时把自己墓地1只名字带有「光子」的怪兽从游戏中除外才能发动。这张卡的攻击力直到结束阶段时上升1000。「光子海盗」的效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36834155,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2,36834155)
	e1:SetCost(c36834155.cost)
	e1:SetOperation(c36834155.operation)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于判断墓地中的卡是否为名字带有「光子」的怪兽，并且是否满足作为发动代价除外的条件。
function c36834155.cfilter(c)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价的处理：检查并选择自己墓地1只名字带有「光子」的怪兽，将其表侧表示除外作为发动代价。
function c36834155.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地是否存在至少1只满足条件的名字带有「光子」的怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c36834155.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示，要求选择一张要除外的卡片（提示信息为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足条件的名字带有「光子」的怪兽，作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c36834155.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽以表侧表示除外（REASON_COST），完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若这张卡仍以表侧表示存在于场上且与发动效果关联，则为这张卡添加攻击力上升1000的效果，该效果持续到结束阶段。
function c36834155.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
