--ウェポンサモナー
-- 效果：
-- ①：这张卡反转的场合发动。从卡组把1张「守护者」卡加入手卡。
function c85489096.initial_effect(c)
	-- ①：这张卡反转的场合发动。从卡组把1张「守护者」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85489096,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c85489096.target)
	e1:SetOperation(c85489096.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动准备与操作信息设置，由于是强制发动的反转效果，chk==0时直接返回true
function c85489096.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果的处理是将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡名含有「守护者」（字段0x52）且可以加入手卡的卡
function c85489096.filter(c)
	return c:IsSetCard(0x52) and c:IsAbleToHand()
end
-- 效果处理：从卡组将1张「守护者」卡加入手卡，并向对方展示确认
function c85489096.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c85489096.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
