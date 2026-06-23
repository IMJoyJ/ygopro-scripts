--コア転送ユニット
-- 效果：
-- 1回合1次，可以丢弃1张手卡，从自己卡组把1张「核成兽的钢核」加入手卡。
function c30770156.initial_effect(c)
	-- 记录此卡具有「核成兽的钢核」这张卡的卡片密码
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
-- 支付效果代价：丢弃1张手卡
function c30770156.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索目标卡片的过滤函数
function c30770156.filter(c)
	return c:IsCode(36623431) and c:IsAbleToHand()
end
-- 设置效果的发动目标：检索满足条件的卡片
function c30770156.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c30770156.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并加入手牌
function c30770156.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c30770156.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
