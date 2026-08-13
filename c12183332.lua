--ショット・ガン・シャッフル
-- 效果：
-- 支付300基本分。自己或对方洗1次卡组。这个效果1回合只能使用1次。
function c12183332.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 支付300基本分。自己或对方洗1次卡组。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12183332,0))  --"洗牌"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c12183332.cost)
	e2:SetTarget(c12183332.target)
	e2:SetOperation(c12183332.operation)
	c:RegisterEffect(e2)
end
-- 发动代价处理：先检查支付条件，再实际支付300基本分。
function c12183332.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查阶段：判定玩家是否能支付300基本分。
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 支付代价：实际扣除300基本分。
	Duel.PayLPCost(tp,300)
end
-- 发动目标判定：不取对象，判定自己或对方卡组是否满足可洗切的条件（至少2张）。
function c12183332.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组或对方卡组数量大于1时才能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 end
end
-- 效果处理：根据双方卡组数量让玩家选择洗自己或对方卡组，然后执行对应洗切；若双方均不可洗则效果不处理。
function c12183332.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt
	-- 检查自己卡组数量是否大于1，结果存入res0。
	local res0=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
	-- 检查对方卡组数量是否大于1，结果存入res1。
	local res1=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1
	if res0 and res1 then
		-- 双方卡组均可洗时，弹出选项让效果发动者选择“自己洗切卡组”或“对方洗切卡组”。
		opt=Duel.SelectOption(tp,aux.Stringid(12183332,1),aux.Stringid(12183332,2))  --"自己洗切卡组/对方洗切卡组"
	elseif res0 then
		-- 仅自己卡组可洗时，只提供“自己洗切卡组”选项。
		opt=Duel.SelectOption(tp,aux.Stringid(12183332,1))  --"自己洗切卡组"
	elseif res1 then
		-- 仅对方卡组可洗时，只提供“对方洗切卡组”选项，并映射为选择对方。
		opt=Duel.SelectOption(tp,aux.Stringid(12183332,2))+1  --"对方洗切卡组"
	else
		return
	end
	if opt==0 then
		-- 洗切自己（发动者）的卡组。
		Duel.ShuffleDeck(tp)
	else
		-- 洗切对方（1-tp）的卡组。
		Duel.ShuffleDeck(1-tp)
	end
end
