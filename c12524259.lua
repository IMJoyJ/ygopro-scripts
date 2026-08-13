--無許可の再奇動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽把可以装备的1只机械族同盟怪兽从手卡·卡组装备。这个效果装备的同盟怪兽在这个回合不能特殊召唤。
function c12524259.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽把可以装备的1只机械族同盟怪兽从手卡·卡组装备。这个效果装备的同盟怪兽在这个回合不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,12524259+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12524259.target)
	e1:SetOperation(c12524259.activate)
	c:RegisterEffect(e1)
end
c12524259.has_text_type=TYPE_UNION
-- 筛选可作为对象的自己场上表侧表示机械族怪兽，且需存在能从手卡·卡组装备给它的机械族同盟怪兽。
function c12524259.tgfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
		-- 检查手卡·卡组是否存在至少1张能够装备给该对象的机械族同盟怪兽。
		and Duel.IsExistingMatchingCard(c12524259.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c,tp)
end
-- 筛选可装备的机械族同盟怪兽：能装备给对象怪兽、是同盟怪兽、机械族、场上无同名卡且不属于禁止卡。
function c12524259.eqfilter(c,tc,tp)
	-- 判断候选卡能否作为同盟装备装备给对象怪兽，并确认对象怪兽允许该同盟装备，且候选卡为同盟怪兽。
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION)
		and c:IsRace(RACE_MACHINE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果发动前检查：魔陷区有空位（若手牌发动需预留1格），存在可装备同盟怪兽的机械族怪兽；发动时选择自己场上1只表侧表示机械族怪兽作为对象。
function c12524259.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE)
	-- 获取自己魔陷区的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12524259.tgfilter(chkc,tp) end
	-- 发动合法性检查：要求魔陷区有空位且场上存在满足条件的机械族怪兽可作为对象。
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c12524259.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象（显示“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示机械族怪兽作为效果的对象。
	Duel.SelectTarget(tp,c12524259.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理：选取对象怪兽，若其仍在场且表侧表示、己方魔陷区有空位，则从手卡·卡组选择1只可装备的机械族同盟怪兽装备给它，并使其本回合不能特殊召唤。
function c12524259.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联且表侧表示，并确认己方魔陷区有空位。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡（显示“请选择要装备的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从手卡·卡组选择1张符合条件的机械族同盟怪兽。
		local g=Duel.SelectMatchingCard(tp,c12524259.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc,tp)
		local ec=g:GetFirst()
		-- 确认选择的同盟怪兽存在且能装备给对象怪兽，然后将其作为装备卡装备。
		if ec and aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
			-- 设置该卡为同盟怪兽状态，使其具备同盟怪兽的特性。
			aux.SetUnionState(ec)
			-- 这个效果装备的同盟怪兽在这个回合不能特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_SZONE)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ec:RegisterEffect(e1)
		end
	end
end
