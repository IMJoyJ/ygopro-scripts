--レプティレス・ガードナー
-- 效果：
-- 自己场上存在的这张卡被破坏送去墓地时，从自己卡组把1只名字带有「爬虫妖」的怪兽加入手卡。
function c43002864.initial_effect(c)
	-- 自己场上存在的这张卡被破坏送去墓地时，从自己卡组把1只名字带有「爬虫妖」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43002864,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c43002864.condition)
	e1:SetTarget(c43002864.target)
	e1:SetOperation(c43002864.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：这张卡因破坏被送去墓地，且破坏前在自己场上并由自己控制（即满足“自己场上存在的这张卡被破坏送去墓地时”）。
function c43002864.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 效果发动目标设定：发动时无条件通过，并预设置把1张卡从卡组加入手卡的操作信息。
function c43002864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果处理信息设置为：从卡组把1张卡加入手卡（检索效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索过滤条件：卡名含有「爬虫妖」的怪兽卡，且能够加入手卡。
function c43002864.filter(c)
	return c:IsSetCard(0x3c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：提示选择加入手卡的卡，从卡组选1张符合条件的怪兽加入手卡，并让对方确认。
function c43002864.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示，提示文本为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选取1张满足c43002864.filter条件的卡片（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c43002864.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
