--堕天使の追放
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把「堕天使的追放」以外的1张「堕天使」卡加入手卡。
function c87112784.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把「堕天使的追放」以外的1张「堕天使」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87112784+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87112784.target)
	e1:SetOperation(c87112784.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「堕天使的追放」以外的「堕天使」卡片且该卡能加入手卡
function c87112784.filter(c)
	return c:IsSetCard(0xef) and not c:IsCode(87112784) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数
function c87112784.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87112784.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理为将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（发动）的执行函数
function c87112784.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c87112784.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
