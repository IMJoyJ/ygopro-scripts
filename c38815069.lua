--ライトロード・シーフ ライニャン
-- 效果：
-- 反转：自己墓地中1张名字带有「光道」的怪兽卡回到卡组，从自己的卡组抽1张卡。
function c38815069.initial_effect(c)
	-- 对应卡牌效果原文：“反转：自己墓地中1张名字带有「光道」的怪兽卡回到卡组，从自己的卡组抽1张卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38815069,0))  --"返回卡组抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c38815069.target)
	e1:SetOperation(c38815069.operation)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤条件：自己墓地中满足名字带有「光道」、是怪兽且可以被送回卡组的卡。
function c38815069.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 反转效果的发动时处理：从自己墓地选择1张符合条件的「光道」怪兽卡作为对象，并设置“回卡组+抽卡”的操作信息；实际处理后由operation执行返回卡组并抽卡。
function c38815069.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38815069.filter(chkc) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1张满足过滤条件且能成为效果对象的「光道」怪兽卡。
	if Duel.IsExistingTarget(c38815069.filter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 向玩家发出选择提示，提示信息为“请选择要返回卡组的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己墓地选择1张满足过滤条件的卡作为效果对象，并记录为当前连锁的对象。
		local g=Duel.SelectTarget(tp,c38815069.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置操作信息：本次连锁处理中包含将1张对象卡返回卡组的分类，目标为已选择的卡。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 设置操作信息：本次连锁处理中包含自己抽1张卡的分类，抽卡玩家为tp。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理：取得发动时选择的对象卡，若该卡仍与效果相关，则将其返回持有者卡组并洗牌；若成功返回且卡仍在卡组或额外卡组，则自己抽1张卡。
function c38815069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动效果时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因、弹回卡组并洗牌的方式将对象卡返回持有者卡组；若返回成功且对象卡仍位于卡组或额外卡组，说明该卡没有被其他效果中途移动，则继续后续处理。
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 如果对象卡返回后位于卡组，则洗切我方卡组，使卡组顺序随机化。
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			-- 自己从卡组抽1张卡，对应效果原文的“从自己的卡组抽1张卡”。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
