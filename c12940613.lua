--マドルチェ・マナー
-- 效果：
-- 选择自己墓地1只名字带有「魔偶甜点」的怪兽回到卡组，自己场上存在的全部名字带有「魔偶甜点」的怪兽的攻击力·守备力上升800。那之后，可以选自己墓地1只怪兽回到卡组。
function c12940613.initial_effect(c)
	-- 效果发动条件：选择自己墓地1只名字带有「魔偶甜点」的怪兽回到卡组，自己场上存在的全部名字带有「魔偶甜点」的怪兽的攻击力·守备力上升800。那之后，可以选自己墓地1只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c12940613.target)
	e1:SetOperation(c12940613.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上名字带有「魔偶甜点」的怪兽。
function c12940613.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 过滤墓地名字带有「魔偶甜点」的怪兽。
function c12940613.tdfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 设置效果的发动目标。
function c12940613.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c12940613.tdfilter1(chkc) end
	-- 检查自己场上是否存在名字带有「魔偶甜点」的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c12940613.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在名字带有「魔偶甜点」的怪兽。
		and Duel.IsExistingTarget(c12940613.tdfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择墓地1只名字带有「魔偶甜点」的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c12940613.tdfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，记录将要返回卡组的卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤墓地所有怪兽。
function c12940613.tdfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 处理效果的发动。
function c12940613.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	-- 获取场上所有名字带有「魔偶甜点」的怪兽。
	local g=Duel.GetMatchingGroup(c12940613.filter,tp,LOCATION_MZONE,0,nil)
	tc=g:GetFirst()
	if not tc then return end
	while tc do
		-- 使场上名字带有「魔偶甜点」的怪兽攻击力上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 获取不受王家长眠之谷影响的墓地所有怪兽。
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12940613.tdfilter2),tp,LOCATION_GRAVE,0,nil)
	-- 询问玩家是否选择墓地一只怪兽回到卡组。
	if dg:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(12940613,0)) then  --"是否要选择墓地一只怪兽回到卡组？"
		-- 中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=dg:Select(tp,1,1,nil)
		-- 显示所选卡作为对象的动画效果。
		Duel.HintSelection(sg)
		-- 将所选卡送回卡组。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
