--ティマイオスの眼
-- 效果：
-- 这个卡名在规则上也当作「传说之龙 蒂迈欧」使用。这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「黑魔术」怪兽为对象才能发动。只用那1只怪兽作为融合素材，把有那个卡名作为融合素材记述的1只融合怪兽融合召唤。
function c1784686.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「黑魔术」怪兽为对象才能发动。只用那1只怪兽作为融合素材，把有那个卡名作为融合素材记述的1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1784686+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1784686.target)
	e1:SetOperation(c1784686.activate)
	c:RegisterEffect(e1)
	-- 这个卡名在规则上也当作「传说之龙 蒂迈欧」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetValue(10000050)
	c:RegisterEffect(e2)
end
-- 定义「黑魔术」怪兽作为融合素材的筛选条件：表侧表示、属于「黑魔术」字段、可作为融合素材、未受必须作为融合素材效果影响，且额外牌组存在可进行融合召唤的融合怪兽。
function c1784686.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10a2) and c:IsCanBeFusionMaterial()
		-- 确认该怪兽没有被“必须作为融合素材”的效果影响，保证其能作为融合素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 确认额外牌组中存在至少1只能够以该怪兽为素材进行融合召唤的融合怪兽。
		and Duel.IsExistingMatchingCard(c1784686.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 定义可作为融合召唤目标的融合怪兽的筛选条件：是融合怪兽、素材记述包含对象怪兽的卡名、能够进行融合召唤、且有可用额外怪兽区空格。
function c1784686.spfilter(c,e,tp,tc)
	-- 筛选额外牌组中的融合怪兽，且其融合素材记述了对象怪兽的当前卡名。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,tc:GetCode())
		-- 确认该融合怪兽能够以融合召唤方式特殊召唤，且额外怪兽区存在可供其出场的空格。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 发动时的对象选择与操作信息设置：选择自己场上1只「黑魔术」怪兽作为对象，并设定将额外融合怪兽进行融合召唤的操作信息。
function c1784686.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc==0 then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1784686.tgfilter(chkc,e,tp) end
	-- 在发动时检查自己场上是否存在1只满足条件的「黑魔术」怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c1784686.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择效果的对象”的提示消息，用于选择卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「黑魔术」怪兽作为效果对象。
	Duel.SelectTarget(tp,c1784686.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置本次连锁包含特殊召唤（融合召唤）的操作信息，用于后续的时点与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时，若对象怪兽仍满足作为融合素材的条件，则选择额外牌组中的融合怪兽，将对象怪兽作为素材送入墓地，并将该融合怪兽融合召唤上场。
function c1784686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时当前的对象怪兽（之前选择的「黑魔术」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍未被“必须作为融合素材”之类的效果影响，仍可作为融合素材。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeFusionMaterial() and not tc:IsImmuneToEffect(e) then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，用于选择融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外牌组选择1只符合条件的融合怪兽作为融合召唤的目标。
		local sg=Duel.SelectMatchingCard(tp,c1784686.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(Group.FromCards(tc))
			-- 将对象怪兽作为融合素材从场上送去墓地（原因包含效果、素材、融合召唤）。
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的融合召唤作为独立事件处理，避免时点被占用。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到自己的场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
