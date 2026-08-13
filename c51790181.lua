--無欲な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己·对方的墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。这张卡发动后，不送去墓地而除外。
function c51790181.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己·对方的墓地的卡合计2张为对象才能发动。那些卡回到持有者卡组。这张卡发动后，不送去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51790181+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51790181.target)
	e1:SetOperation(c51790181.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的取对象处理：先判断是否处于取对象回合计时（chkc），再检查是否存在满足条件的墓地卡作为发动前提，然后选择2张墓地卡为对象，并设置回卡组的处理信息。
function c51790181.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动合法性检查（chk==0）时，确认双方墓地存在至少2张能够返回卡组的卡，以满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
	-- 向玩家显示提示消息，要求其选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方墓地选择2张能够回卡组的卡，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
	-- 设置当前连锁的操作信息：本效果后续会把对象卡送回卡组，数量为2张。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理时的执行操作：获取连锁对象，筛选出仍与效果关联的卡，将它们洗回持有者卡组；若此卡仍在场上且是发动效果，则将其除外。
function c51790181.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁登记的对象卡组，即发动时选择的那2张墓地卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡以效果原因送回持有者卡组，并触发洗牌。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if e:GetHandler():IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 将发动后的这张卡以表侧表示除外，而不是送入墓地。
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
