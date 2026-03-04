--クリティウスの牙
-- 效果：
-- 这张卡的卡名在规则上也当作「传说之龙 克里底亚」使用。「克里底亚之牙」在1回合只能发动1张。
-- ①：「克里底亚之牙」的效果才能特殊召唤的融合怪兽卡记述的1张陷阱卡从自己的手卡·场上送去墓地（那张卡在场上盖放的场合，翻开确认）。那之后，把那1只融合怪兽从额外卡组特殊召唤。
function c11082056.initial_effect(c)
	-- 效果原文内容：「克里底亚之牙」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11082056+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11082056.target)
	e1:SetOperation(c11082056.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡的卡名在规则上也当作「传说之龙 克里底亚」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(10000060)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡或场上的陷阱卡是否能作为融合怪兽的素材。
function c11082056.tgfilter(c,e,tp)
	-- 判断该陷阱卡是否能作为融合怪兽的素材，并且是否存在满足条件的融合怪兽。
	return c:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(c11082056.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),c)
end
-- 过滤函数，用于判断额外卡组中是否存在满足条件的融合怪兽。
function c11082056.spfilter(c,e,tp,code,tc)
	return c:IsType(TYPE_FUSION) and c.material_trap and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and code==c.material_trap
		-- 判断目标融合怪兽是否能在场上特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 效果处理时的判断函数，用于确定是否满足发动条件。
function c11082056.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11082056.tgfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示将要特殊召唤1只融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，用于执行发动效果时的操作。
function c11082056.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要作为融合素材的陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	-- 选择满足条件的陷阱卡作为融合素材。
	local g=Duel.SelectMatchingCard(tp,c11082056.tgfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 若陷阱卡在场上盖放，则翻开确认其内容。
		if tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
		local code=tc:GetCode()
		-- 将所选陷阱卡送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if not tc:IsLocation(LOCATION_GRAVE) then return end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的融合怪兽进行特殊召唤。
		local sg=Duel.SelectMatchingCard(tp,c11082056.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code,nil)
		local sc=sg:GetFirst()
		if sc then
			-- 中断当前效果处理，使后续效果视为错时处理。
			Duel.BreakEffect()
			-- 将融合怪兽从额外卡组特殊召唤到场上。
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
