--ジェムナイト・サニクス
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「宝石骑士」的卡加入手卡。
function c43114901.initial_effect(c)
	-- 为该卡启用二重怪兽机制：在墓地或场上表侧表示时当作通常怪兽，并允许通过再度召唤变成效果怪兽以取得后续效果。
	aux.EnableDualAttribute(c)
	-- ●这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「宝石骑士」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43114901,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43114901.thcon)
	e1:SetTarget(c43114901.thtg)
	e1:SetOperation(c43114901.thop)
	c:RegisterEffect(e1)
end
-- 定义诱发效果的发动条件：本卡处于再度召唤后的效果怪兽状态，且只有1只对方怪兽被本卡战斗破坏并送去墓地时才满足条件。
function c43114901.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若该卡尚未进入再度召唤状态（仍当作通常怪兽），则不能发动本效果。
	if not aux.IsDualState(e) then return false end
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 定义检索卡牌时的过滤条件：卡名含有「宝石骑士」字段（0x1047）且能够加入手卡。
function c43114901.filter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 定义效果发动时的目标阶段处理：确认卡组中存在可检索的「宝石骑士」卡，并登记将1张卡从卡组加入手牌的操作信息。
function c43114901.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：若自己卡组中没有满足条件的「宝石骑士」卡，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43114901.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次效果将把1张卡从卡组加入手牌（CATEGORY_TOHAND），来源区域为卡组，供其他效果正确响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理时的执行操作：从自己卡组选择1张满足条件的「宝石骑士」卡加入手牌，并向对方展示。
function c43114901.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，告知玩家需要选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张满足条件的「宝石骑士」卡。
	local g=Duel.SelectMatchingCard(tp,c43114901.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
