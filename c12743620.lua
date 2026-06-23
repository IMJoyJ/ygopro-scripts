--ユニゾン・チューン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或者对方的墓地1只调整和场上1只表侧表示怪兽为对象才能发动。作为对象的墓地的怪兽除外。那之后，作为对象的场上的怪兽直到回合结束时变成和除外的怪兽相同等级，当作调整使用。
function c12743620.initial_effect(c)
	-- ①：以自己或者对方的墓地1只调整和场上1只表侧表示怪兽为对象才能发动。作为对象的墓地的怪兽除外。那之后，作为对象的场上的怪兽直到回合结束时变成和除外的怪兽相同等级，当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12743620+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12743620.target)
	e1:SetOperation(c12743620.activate)
	c:RegisterEffect(e1)
end
-- 过滤墓地中的调整怪兽，确保其等级大于0且可以被除外，并且场上存在满足条件的怪兽作为目标。
function c12743620.filter1(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		-- 检查场上是否存在满足条件的怪兽（即不是调整或等级不等于除外调整的等级），用于选择作为效果对象的场上怪兽。
		and Duel.IsExistingTarget(c12743620.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lv)
end
-- 过滤场上满足条件的怪兽，即正面表示且等级大于等于1，且不是调整或等级不等于指定等级的怪兽。
function c12743620.filter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and (not c:IsType(TYPE_TUNER) or not c:IsLevel(lv))
end
-- 效果处理时的处理函数，用于选择效果对象。
function c12743620.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件，即在墓地中存在符合条件的调整怪兽。
	if chk==0 then return Duel.IsExistingTarget(c12743620.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 提示玩家选择要除外的墓地中的调整怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择墓地中的调整怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c12743620.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要变更等级和类型的场上怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择场上正面表示的怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,c12743620.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g1:GetFirst():GetLevel())
	if g1:GetFirst():IsControler(tp) then
		-- 设置操作信息，表示将要除外的卡来自自己墓地。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,tp,LOCATION_GRAVE)
	else
		-- 设置操作信息，表示将要除外的卡来自对方墓地。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,1-tp,LOCATION_GRAVE)
	end
end
-- 效果发动时的处理函数，用于执行效果。
function c12743620.activate(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁的效果对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	-- 判断除外的调整怪兽是否仍然在场，且成功除外，然后进行后续处理。
	if hc:IsRelateToEffect(e) and Duel.Remove(hc,POS_FACEUP,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_REMOVED) then
		-- 中断当前效果处理，使之后的效果视为不同时处理。
		Duel.BreakEffect()
		-- 将目标怪兽的等级设置为除外调整怪兽的等级，并添加调整属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(hc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e2)
	end
end
