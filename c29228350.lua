--ドラゴンレーザー
-- 效果：
-- 把自己场上表侧表示存在的「三角三」装备的1只「三角火龙」送去墓地，对方场上存在的怪兽全部破坏。
function c29228350.initial_effect(c)
	-- 把自己场上表侧表示存在的「三角三」装备的1只「三角火龙」送去墓地，对方场上存在的怪兽全部破坏。
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
-- 定义筛选函数：检查魔陷区的卡是否为「三角火龙」（卡号48568432），并且其装备对象是自己场上表侧表示存在的「三角三」（卡号12079734）。
function c29228350.filter(c,tp)
	local ec=c:GetEquipTarget()
	return ec and c:IsCode(48568432) and ec:IsControler(tp) and ec:IsCode(12079734)
end
-- 效果发动时的目标选择与合法性判断：若指定了对象则检查该对象是否合法；否则在非处理阶段确认存在符合条件的「三角火龙」装备卡以及对方场上存在怪兽，满足条件才可发动。
function c29228350.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c29228350.filter(chkc,tp) end
	-- 非效果处理时，检查场上是否存在1张可以成为对象的「三角火龙」装备卡（即装备着「三角三」的「三角火龙」）。
	if chk==0 then return Duel.IsExistingTarget(c29228350.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,tp)
		-- 同时确认对方场上有至少1只怪兽存在，以保证破坏效果能够处理。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示消息，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己或对方的魔陷区选择1张符合条件的「三角火龙」装备卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c29228350.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,tp)
	-- 设置本次效果处理的送入墓地操作信息：将选中的「三角火龙」送去墓地，数量为1，用于后续与“送去墓地”相关的连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 获取对方场上当前存在的全部怪兽（无条件筛选），用于设置破坏效果的操作信息。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置本次效果处理的破坏操作信息：对方场上的全部怪兽都将被破坏，数量为当前怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：将作为对象的「三角火龙」送去墓地，若成功送去墓地，则将对方场上存在的怪兽全部破坏。
function c29228350.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的那张「三角火龙」对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查该对象卡仍然与当前效果关联，并成功将其送入墓地；只有完成这一操作才继续执行后续的破坏效果。
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- 效果处理时重新获取对方场上当前存在的全部怪兽，确保破坏范围是最新状态。
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 将对方场上的所有怪兽全部破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
