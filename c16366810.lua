--イエロー・ダストン
-- 效果：
-- 这张卡不能解放，也不能作为融合·同调·超量召唤的素材。场上的这张卡被破坏时，这张卡的控制者选择自己墓地1只怪兽回到卡组。「黄尘妖」在自己场上只能有1只表侧表示存在。
function c16366810.initial_effect(c)
	c:SetUniqueOnField(1,0,16366810)
	-- 这张卡不能解放（作为上级召唤的祭品）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- 也不能作为融合·同调·超量召唤的素材（融合素材部分）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(c16366810.fuslimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)
	-- 场上的这张卡被破坏时，这张卡的控制者选择自己墓地1只怪兽回到卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(16366810,0))  --"返回卡组"
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c16366810.retcon)
	e6:SetTarget(c16366810.rettg)
	e6:SetOperation(c16366810.retop)
	c:RegisterEffect(e6)
end
-- 判断融合召唤的素材种类，当这张卡被用作融合素材时返回 true，使其不能作为融合素材。
function c16366810.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
-- 发动条件：这张卡因被破坏而离开场上，且破坏前位于场上。
function c16366810.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择对象条件：对象必须是墓地中的怪兽，并且可以被送回卡组。
function c16366810.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 取对象处理：以这张卡破坏前的控制者为准，选择其墓地1只符合条件的怪兽为对象，并设置回卡组的操作信息。
function c16366810.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local prec=e:GetHandler():GetPreviousControler()
	if chkc then return chkc:IsControler(prec) and chkc:IsLocation(LOCATION_GRAVE) and c16366810.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家显示选择提示文字「请选择要返回卡组的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让这张卡破坏前的控制者从自己的墓地选择1只满足 c16366810.filter 的怪兽作为效果对象。
	local g=Duel.SelectTarget(prec,c16366810.filter,prec,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息为回卡组，对象为已选择的卡，数量为其数量，便于其他效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：若对象卡仍与效果关联，将该卡送回持有者卡组并洗牌。
function c16366810.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回其持有者卡组，并执行洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
