--エクシーズ・オーバーディレイ
-- 效果：
-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。
-- ①：以持有超量素材的对方场上1只超量怪兽为对象才能发动。那只怪兽的超量素材全部取除，作为对象的怪兽回到额外卡组。取除的超量素材之中有怪兽卡的场合，再把那些怪兽从墓地尽可能往对方场上守备表示特殊召唤。这个效果特殊召唤的怪兽的等级下降1星。
function c78610936.initial_effect(c)
	-- 不能对应这张卡的发动让魔法·陷阱·怪兽的效果发动。①：以持有超量素材的对方场上1只超量怪兽为对象才能发动。那只怪兽的超量素材全部取除，作为对象的怪兽回到额外卡组。取除的超量素材之中有怪兽卡的场合，再把那些怪兽从墓地尽可能往对方场上守备表示特殊召唤。这个效果特殊召唤的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c78610936.target)
	e1:SetOperation(c78610936.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对方场上表侧表示、持有超量素材且能回到额外卡组的超量怪兽
function c78610936.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAbleToExtra() and c:GetOverlayCount()>0
end
-- 效果发动时的对象选择与连锁限制处理
function c78610936.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c78610936.filter(chkc) end
	-- 检查对方场上是否存在符合条件的、可作为效果对象的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c78610936.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择对方场上1只符合条件的超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78610936.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示该效果包含将选中的卡送回额外卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 限制连锁，使得任何玩家都不能对应这张卡的发动来发动效果
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 过滤条件：存在于墓地且可以往对方场上表侧守备表示特殊召唤的怪兽
function c78610936.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果处理的核心逻辑，包括取除素材、返回额外卡组、以及从墓地特殊召唤并降低等级
function c78610936.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetOverlayGroup()
	-- 将作为对象怪兽的所有超量素材送去墓地（即取除超量素材）
	Duel.SendtoGrave(mg,REASON_EFFECT)
	-- 将作为对象的超量怪兽送回额外卡组，并确认是否成功返回
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
		-- 筛选出刚才取除的超量素材中，不受王家长眠之谷影响且可以特殊召唤的怪兽卡
		local g=mg:Filter(aux.NecroValleyFilter(c78610936.spfilter),nil,e,tp)
		-- 获取对方场上可用于特殊召唤怪兽的空余怪兽区域数量
		local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if ft>0 and g:GetCount()>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			if g:GetCount()>ft then
				-- 提示玩家选择要特殊召唤的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				g=g:Select(tp,ft,ft,nil)
			end
			local tc=g:GetFirst()
			while tc do
				-- 将怪兽以表侧守备表示特殊召唤到对方场上（分步处理）
				Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
				if tc:GetLevel()>0 then
					-- 这个效果特殊召唤的怪兽的等级下降1星。
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_LEVEL)
					e1:SetValue(-1)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
				end
				tc=g:GetNext()
			end
			-- 完成所有分步特殊召唤的怪兽的特殊召唤程序
			Duel.SpecialSummonComplete()
		end
	end
end
