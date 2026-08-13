--クリティウスの牙
-- 效果：
-- 这张卡的卡名在规则上也当作「传说之龙 克里底亚」使用。「克里底亚之牙」在1回合只能发动1张。
-- ①：「克里底亚之牙」的效果才能特殊召唤的融合怪兽卡记述的1张陷阱卡从自己的手卡·场上送去墓地（那张卡在场上盖放的场合，翻开确认）。那之后，把那1只融合怪兽从额外卡组特殊召唤。
function c11082056.initial_effect(c)
	-- 「克里底亚之牙」在1回合只能发动1张。①：『克里底亚之牙』的效果才能特殊召唤的融合怪兽卡记述的1张陷阱卡从自己的手卡·场上送去墓地（那张卡在场上盖放的场合，翻开确认）。那之后，把那1只融合怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11082056+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11082056.target)
	e1:SetOperation(c11082056.activate)
	c:RegisterEffect(e1)
	-- 这张卡的卡名在规则上也当作「传说之龙 克里底亚」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(10000060)
	c:RegisterEffect(e2)
end
-- 定义融合素材陷阱卡的筛选函数：该卡须为陷阱卡，且额外卡组存在至少1只以其卡名为素材、可被本次效果特殊召唤的融合怪兽。
function c11082056.tgfilter(c,e,tp)
	-- 筛选条件：候选卡必须是陷阱卡，并且额外卡组中存在至少1只对应素材卡名的融合怪兽可被特殊召唤。
	return c:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(c11082056.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),c)
end
-- 定义融合怪兽的筛选函数：该怪兽须为融合怪兽，其记录了所需陷阱卡卡号（c.material_trap），满足特殊召唤条件，且额外怪兽区域有可用空格。
function c11082056.spfilter(c,e,tp,code,tc)
	return c:IsType(TYPE_FUSION) and c.material_trap and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and code==c.material_trap
		-- 额外判定：扣除素材陷阱卡离场后的空位后，仍有足够区域可供该融合怪兽特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 发动时的处理：在发动阶段检查是否存在符合条件的陷阱卡素材，并设置本次连锁将进行特殊召唤的操作信息。
function c11082056.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认我方手卡·魔陷区存在至少1张满足条件的陷阱卡（且额外有对应融合怪兽可特殊召唤）。
	if chk==0 then return Duel.IsExistingMatchingCard(c11082056.tgfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,e,tp) end
	-- 设置操作信息：预定从额外卡组特殊召唤1只怪兽，供后续效果检测和连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择1张符合条件的陷阱卡作为素材，若场上里侧表示则翻开展示，将其送入墓地，若成功送墓则选择对应的融合怪兽特殊召唤，并完成特殊召唤手续。
function c11082056.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要作为融合素材的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
	-- 让玩家从我方手卡·魔陷区选择1张符合条件的陷阱卡作为融合素材。
	local g=Duel.SelectMatchingCard(tp,c11082056.tgfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 若选择的陷阱卡在我方场上里侧表示，则向对方公开确认该卡内容。
		if tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
		local code=tc:GetCode()
		-- 将选择的陷阱卡以效果原因送入墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if not tc:IsLocation(LOCATION_GRAVE) then return end
		-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只符合条件的融合怪兽（其素材陷阱卡卡号与已送墓的陷阱卡一致）。
		local sg=Duel.SelectMatchingCard(tp,c11082056.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code,nil)
		local sc=sg:GetFirst()
		if sc then
			-- 中断当前效果处理，使后续特殊召唤视为另一次独立处理，避免错时点。
			Duel.BreakEffect()
			-- 将选中的融合怪兽以表侧表示特殊召唤到场上（无视召唤条件与苏生限制），随后完成正规召唤手续。
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
