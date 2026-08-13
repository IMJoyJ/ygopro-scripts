--ジェネクス・パワー・プランナー
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只3星「次世代」效果怪兽加入手卡。
function c30399511.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只3星「次世代」效果怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30399511,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c30399511.target)
	e1:SetOperation(c30399511.operation)
	c:RegisterEffect(e1)
end
-- 筛选卡组中满足3星、「次世代」字段、效果怪兽类型且能加入手卡的卡片。
function c30399511.filter(c)
	return c:IsLevel(3) and c:IsSetCard(0x2) and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 效果发动时的合法性检查：确认卡组中存在满足条件的卡，并登记检索加入手卡的操作信息。
function c30399511.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查自己卡组中是否存在至少1张满足检索条件的「次世代」效果怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30399511.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁的操作信息为从卡组把1张卡加入手卡（类别为检索+回手牌）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时从卡组选择1张满足条件的「次世代」效果怪兽加入手卡，并让对方确认。
function c30399511.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足filter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c30399511.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
