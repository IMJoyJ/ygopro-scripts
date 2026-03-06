--ドラゴンレーザー
-- 效果：
-- 把自己场上表侧表示存在的「三角三」装备的1只「三角火龙」送去墓地，对方场上存在的怪兽全部破坏。
function c29228350.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的「三角三」装备的1只「三角火龙」送去墓地，对方场上存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c29228350.target)
	e1:SetOperation(c29228350.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的装备卡，即装备在自己控制的「三角三」上的「三角火龙」
function c29228350.filter(c,tp)
	local ec=c:GetEquipTarget()
	return ec and c:IsCode(48568432) and ec:IsControler(tp) and ec:IsCode(12079734)
end
-- 效果作用：设置效果目标，选择自己场上装备的「三角火龙」
function c29228350.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c29228350.filter(chkc,tp) end
	-- 效果作用：检查自己场上是否存在满足条件的装备怪兽
	if chk==0 then return Duel.IsExistingTarget(c29228350.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,tp)
		-- 效果作用：检查对方场上是否存在至少1只怪兽
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择满足条件的装备卡作为效果对象
	local g=Duel.SelectTarget(tp,c29228350.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,tp)
	-- 效果作用：设置效果处理信息，将选择的装备卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 效果作用：获取对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置效果处理信息，将对方场上的所有怪兽破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果原文内容：把自己场上表侧表示存在的「三角三」装备的1只「三角火龙」送去墓地，对方场上存在的怪兽全部破坏。
function c29228350.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标卡是否仍然存在于场上并成功将其送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- 效果作用：获取对方场上的所有怪兽
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 效果作用：将对方场上的所有怪兽破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
