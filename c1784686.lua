--ティマイオスの眼
-- 效果：
-- 这个卡名在规则上也当作「传说之龙 蒂迈欧」使用。这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「黑魔术」怪兽为对象才能发动。只用那1只怪兽作为融合素材，把有那个卡名作为融合素材记述的1只融合怪兽融合召唤。
function c1784686.initial_effect(c)
	-- ①：以自己场上1只「黑魔术」怪兽为对象才能发动。只用那1只怪兽作为融合素材，把有那个卡名作为融合素材记述的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1784686+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1784686.target)
	e1:SetOperation(c1784686.activate)
	c:RegisterEffect(e1)
	-- 这个卡名在规则上也当作「传说之龙 蒂迈欧」使用。这个卡名的卡在1回合只能发动1张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetValue(10000050)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否满足作为融合素材的条件，包括是否为黑魔术卡组、是否能作为融合素材、是否能融合召唤出符合条件的融合怪兽。
function c1784686.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10a2) and c:IsCanBeFusionMaterial()
		-- 检测目标怪兽是否必须作为融合素材，确保其能被用于融合召唤。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查场上是否存在满足条件的融合怪兽，用于后续的融合召唤操作。
		and Duel.IsExistingMatchingCard(c1784686.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数，用于筛选能通过指定融合素材进行融合召唤的融合怪兽。
function c1784686.spfilter(c,e,tp,tc)
	-- 判断融合怪兽是否具有指定的融合素材卡名，确保融合召唤的正确性。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,tc:GetCode())
		-- 判断融合怪兽是否能被特殊召唤，同时检查是否有足够的召唤位置。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 设置效果的目标选择逻辑，确保选择的怪兽满足条件。
function c1784686.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc==0 then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1784686.tgfilter(chkc,e,tp) end
	-- 检查是否满足发动条件，即场上是否存在符合条件的黑魔术怪兽。
	if chk==0 then return Duel.IsExistingTarget(c1784686.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象，即选择一只黑魔术怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只符合条件的黑魔术怪兽作为效果对象。
	Duel.SelectTarget(tp,c1784686.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，表示将要特殊召唤一只融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时的处理函数，负责执行融合召唤操作。
function c1784686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 再次检测目标怪兽是否必须作为融合素材，防止无效操作。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeFusionMaterial() and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的融合怪兽进行特殊召唤。
		local sg=Duel.SelectMatchingCard(tp,c1784686.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(Group.FromCards(tc))
			-- 将目标怪兽送入墓地，作为融合召唤的素材处理。
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，确保后续操作不会与当前效果冲突。
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上，完成融合召唤操作。
			Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
