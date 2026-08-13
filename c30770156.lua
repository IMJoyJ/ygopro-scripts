--コア転送ユニット
-- 效果：
-- 1回合1次，可以丢弃1张手卡，从自己卡组把1张「核成兽的钢核」加入手卡。
function c30770156.initial_effect(c)
	-- 将卡号36623431（「核成兽的钢核」）登记为这张卡效果文所提及的关联卡，便于后续检索判定。
	aux.AddCodeList(c,36623431)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，可以丢弃1张手卡，从自己卡组把1张「核成兽的钢核」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30770156,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30770156.cost)
	e2:SetTarget(c30770156.target)
	e2:SetOperation(c30770156.operation)
	c:RegisterEffect(e2)
end
-- 定义发动代价函数：检查并执行丢弃1张手卡作为发动代价。
function c30770156.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段检查自己手牌中是否存在至少1张可以丢弃的卡（不包含本卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌选择1张手卡丢弃，丢弃原因记为“代价并丢弃”。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索卡片的过滤条件：必须是「核成兽的钢核」（卡号36623431）且当前可以被加入手卡。
function c30770156.filter(c)
	return c:IsCode(36623431) and c:IsAbleToHand()
end
-- 定义发动目标函数：确认卡组中存在可检索的「核成兽的钢核」，并声明本次效果将进行回手牌检索。
function c30770156.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标确认阶段检查自己卡组中是否存在至少1张满足filter条件的「核成兽的钢核」。
	if chk==0 then return Duel.IsExistingMatchingCard(c30770156.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，向系统声明本连锁将以从卡组将1张卡加入手牌的方式处理，用于正确触发相关效果与时点。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数：实际从卡组挑选1张「核成兽的钢核」加入手牌，并向对手展示该卡。
function c30770156.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示，让玩家从卡组选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选出1张满足filter条件的「核成兽的钢核」作为效果处理对象。
	local g=Duel.SelectMatchingCard(tp,c30770156.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「核成兽的钢核」以效果原因送入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
