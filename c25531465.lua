--マジキャット
-- 效果：
-- 这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以让自己墓地存在的1张魔法卡回到卡组最上面。
function c25531465.initial_effect(c)
	-- 这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以让自己墓地存在的1张魔法卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25531465,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c25531465.tdcon)
	e1:SetTarget(c25531465.tdtg)
	e1:SetOperation(c25531465.tdop)
	c:RegisterEffect(e1)
end
-- 效果触发条件：此卡因作为魔法师族怪兽的同调素材被送去墓地，且当前位于墓地时才满足条件。
function c25531465.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_SPELLCASTER)
end
-- 筛选墓地中符合条件的卡：是魔法卡且可以返回卡组。
function c25531465.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 选择效果对象：从自己墓地选择1张符合条件的魔法卡，并登记其回卡组的操作信息。
function c25531465.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c25531465.filter(chkc) end
	-- 发动前检查自己墓地是否存在至少1张符合条件的魔法卡作为取对象候选。
	if chk==0 then return Duel.IsExistingTarget(c25531465.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家展示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的魔法卡，并设为效果对象。
	local g=Duel.SelectTarget(tp,c25531465.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次操作信息：处理分类为回卡组，对象为所选卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：取回效果对象卡，若仍与该效果关联则将其送回持有者卡组最上方。
function c25531465.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡以效果送回其持有者卡组的最上方（不洗牌）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
