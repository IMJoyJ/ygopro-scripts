--鉄獣の凶襲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。那只怪兽的攻击力以下而种族不同的1只兽族·兽战士族·鸟兽族怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。这个效果的发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
function c51097887.initial_effect(c)
	-- ①：以自己场上1只兽族·兽战士族·鸟兽族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,51097887+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c51097887.sptg)
	e1:SetOperation(c51097887.spop)
	c:RegisterEffect(e1)
end
-- 选择满足条件的怪兽作为效果对象，该怪兽必须是表侧表示且种族为兽族、兽战士族或鸟兽族。
function c51097887.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 检查在自己卡组中是否存在满足条件的怪兽（种族不同、攻击力不超过目标怪兽），用于后续特殊召唤。
		and Duel.IsExistingMatchingCard(c51097887.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttack(),c:GetRace())
end
-- 筛选卡组中满足条件的怪兽：种族为兽族、兽战士族或鸟兽族，攻击力不超过目标怪兽，且种族与目标怪兽不同，并能以守备表示特殊召唤。
function c51097887.spfilter2(c,e,tp,atk,race)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAttackBelow(atk) and not c:IsRace(race)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理效果发动时的条件判断，检查是否满足发动条件（场上存在符合条件的目标怪兽）。
function c51097887.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c51097887.spfilter1(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		-- 检查自己场上是否存在满足条件的目标怪兽。
		and Duel.IsExistingTarget(c51097887.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c51097887.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将从卡组特殊召唤一张怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作，包括选择并特殊召唤符合条件的怪兽，并对其效果进行无效化。
function c51097887.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍然存在于场上且为表侧表示，同时自己场上存在可用区域。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家从卡组中选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 在卡组中选择满足条件的怪兽（种族不同、攻击力不超过目标怪兽）。
		local g=Duel.SelectMatchingCard(tp,c51097887.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttack(),tc:GetRace())
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽以守备表示特殊召唤到场上。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 使该特殊召唤的怪兽效果直到回合结束时无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			-- 完成所有特殊召唤步骤，确保效果正确处理。
			Duel.SpecialSummonComplete()
		end
	end
	-- 发动后，直到回合结束时自己不是连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c51097887.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个场上的效果，禁止玩家从额外卡组特殊召唤非连接怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：只有当怪兽不是连接类型且位于额外卡组时才生效。
function c51097887.splimit(e,c)
	return not c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_EXTRA)
end
