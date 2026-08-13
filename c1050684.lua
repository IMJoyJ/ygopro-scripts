--スクラップ・エリア
-- 效果：
-- ①：从卡组把1只「废铁」调整加入手卡。
function c1050684.initial_effect(c)
	-- ①：从卡组把1只「废铁」调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1050684.target)
	e1:SetOperation(c1050684.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡组中满足「废铁」字段、调整为怪兽、且能被加入手卡的卡片。
function c1050684.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 发动条件与操作信息设定：确认卡组存在符合条件的「废铁」调整，并预宣告本次效果为从卡组检索加入手卡。
function c1050684.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1只符合筛选条件的「废铁」调整时才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1050684.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理为从卡组将1张卡加入手牌，并标记检索/回手类别，供相关卡效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「废铁」调整加入手牌，并展示给对方玩家确认。
function c1050684.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选出1只满足条件的「废铁」调整。
	local g=Duel.SelectMatchingCard(tp,c1050684.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
