--無許可の再奇動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽把可以装备的1只机械族同盟怪兽从手卡·卡组装备。这个效果装备的同盟怪兽在这个回合不能特殊召唤。
function c12524259.initial_effect(c)
	-- 创建卡牌效果，设置为发动时点，可选择对象，限制发动次数为1次
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
-- 过滤函数，用于判断场上是否有满足条件的机械族怪兽（正面表示）
function c12524259.tgfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
		-- 检查场上该机械族怪兽是否可以装备手卡或卡组中的机械族同盟怪兽
		and Duel.IsExistingMatchingCard(c12524259.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c,tp)
end
-- 过滤函数，用于判断手卡或卡组中是否有满足条件的机械族同盟怪兽
function c12524259.eqfilter(c,tc,tp)
	-- 检查该同盟怪兽是否能装备给目标怪兽，且为同盟类型
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION)
		and c:IsRace(RACE_MACHINE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 设置效果目标选择函数，用于选择场上满足条件的机械族怪兽
function c12524259.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsLocation(LOCATION_SZONE)
	-- 获取玩家当前场上魔陷区的可用空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12524259.tgfilter(chkc,tp) end
	-- 判断是否满足发动条件，即场上存在可用空位且存在符合条件的怪兽
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c12524259.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的场上机械族怪兽作为效果对象
	Duel.SelectTarget(tp,c12524259.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 设置效果发动时的处理函数
function c12524259.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效，且场上存在空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的同盟怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		-- 从手卡或卡组中选择满足条件的同盟怪兽
		local g=Duel.SelectMatchingCard(tp,c12524259.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc,tp)
		local ec=g:GetFirst()
		-- 判断选择的同盟怪兽是否能装备给目标怪兽并执行装备
		if ec and aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
			-- 为装备的同盟怪兽添加同盟状态
			aux.SetUnionState(ec)
			-- 装备的同盟怪兽在本回合不能特殊召唤
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
