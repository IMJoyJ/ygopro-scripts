--悪魔の嘆き
-- 效果：
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽回到对方卡组。那之后，可以从自己卡组把1只恶魔族怪兽送去墓地。
function c60743819.initial_effect(c)
	-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽回到对方卡组。那之后，可以从自己卡组把1只恶魔族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c60743819.target)
	e1:SetOperation(c60743819.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方墓地中可以回到卡组的怪兽卡
function c60743819.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 发动时的效果处理，确认发动条件并选择对方墓地1只怪兽作为对象
function c60743819.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c60743819.filter(chkc) end
	-- 检查对方墓地是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(c60743819.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c60743819.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤自己卡组中可以送去墓地的恶魔族怪兽
function c60743819.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 效果处理，使作为对象的怪兽回到卡组，并可以从自己卡组把1只恶魔族怪兽送去墓地
function c60743819.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其返回持有者卡组并洗牌，若成功返回则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取自己卡组中所有可以送去墓地的恶魔族怪兽
		local g=Duel.GetMatchingGroup(c60743819.tgfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在符合条件的怪兽，询问玩家是否选择将1只恶魔族怪兽送去墓地
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(60743819,0)) then  --"是否把1只恶魔族怪兽送去墓地？"
			-- 中断当前效果，使后续的送去墓地处理与返回卡组处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的恶魔族怪兽送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
