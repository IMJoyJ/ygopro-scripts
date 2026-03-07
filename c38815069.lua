--ライトロード・シーフ ライニャン
-- 效果：
-- 反转：自己墓地中1张名字带有「光道」的怪兽卡回到卡组，从自己的卡组抽1张卡。
function c38815069.initial_effect(c)
	-- 反转：自己墓地中1张名字带有「光道」的怪兽卡回到卡组，从自己的卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38815069,0))  --"返回卡组抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c38815069.target)
	e1:SetOperation(c38815069.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的墓地怪兽卡（名字带有光道、是怪兽卡、可以送回卡组）
function c38815069.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置效果目标为己方墓地满足条件的怪兽卡
function c38815069.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38815069.filter(chkc) end
	if chk==0 then return true end
	-- 判断己方墓地是否存在满足条件的怪兽卡
	if Duel.IsExistingTarget(c38815069.filter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1张满足条件的墓地怪兽卡作为效果对象
		local g=Duel.SelectTarget(tp,c38815069.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置效果处理信息：将1张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 设置效果处理信息：从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理函数：将选中的卡送回卡组并抽1张卡
function c38815069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组并判断是否成功送回卡组或额外卡组
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			-- 如果送回的是卡组，则洗切卡组
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			-- 从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
