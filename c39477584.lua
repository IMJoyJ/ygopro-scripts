--魔轟神レヴュアタン
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡被破坏送去墓地时，以自己墓地最多3只「魔轰神」怪兽为对象才能发动。那些怪兽加入手卡。
function c39477584.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整怪兽必须为「魔轰神」怪兽，调整以外的怪兽任意1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡被破坏送去墓地时，以自己墓地最多3只「魔轰神」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39477584,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c39477584.con)
	e1:SetTarget(c39477584.tg)
	e1:SetOperation(c39477584.op)
	c:RegisterEffect(e1)
end
-- 发动条件判定：这张卡是被效果等原因破坏并送去墓地，且破坏前位于场上。
function c39477584.con(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 对象过滤条件：墓地中满足「魔轰神」字段、是怪兽且能够加入手卡的卡。
function c39477584.filter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时选择自己墓地1～3只符合条件的「魔轰神」怪兽作为对象，并设置本次操作的回手牌信息。
function c39477584.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39477584.filter(chkc) end
	-- 发动合法性检查：自己的墓地是否存在至少1只符合条件的「魔轰神」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c39477584.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1～3只符合条件的「魔轰神」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c39477584.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置连锁处理信息：本次效果将把选择的对象卡加入手牌，数量为已选卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：取得效果对象，筛选出仍与该效果关联的卡，将其加入手牌并向对方展示。
function c39477584.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将这些对象卡送回持有者的手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
