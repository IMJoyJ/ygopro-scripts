--ヘルモスの爪
-- 效果：
-- 这张卡的卡名在规则上也当作「传说之龙 赫谟」使用。「赫谟之爪」在1回合只能发动1张。
-- ①：「赫谟之爪」的效果才能特殊召唤的融合怪兽卡记述的种族的1只怪兽从自己的手卡·场上送去墓地（那张卡在场上盖放的场合，翻开确认）。那之后，把那1只融合怪兽从额外卡组特殊召唤。
function c46232525.initial_effect(c)
	-- 「赫谟之爪」在1回合只能发动1张。①：「赫谟之爪」的效果才能特殊召唤的融合怪兽卡记述的种族的1只怪兽从自己的手卡·场上送去墓地（那张卡在场上盖放的场合，翻开确认）。那之后，把那1只融合怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46232525+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46232525.target)
	e1:SetOperation(c46232525.activate)
	c:RegisterEffect(e1)
	-- 这张卡的卡名在规则上也当作「传说之龙 赫谟」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(10000070)
	c:RegisterEffect(e2)
end
-- 素材怪兽的过滤函数：判断一张怪兽卡是否可作为本次效果的融合素材，要求其本身是怪兽，且额外卡组中存在1只与该怪兽种族对应的融合怪兽，并能通过本效果特殊召唤。
function c46232525.tgfilter(c,e,tp)
	-- 检查当前候选卡是怪兽，并以该怪兽的种族为参数，在额外卡组中检索是否存在至少1张满足spfilter的融合怪兽（种族一致、可特殊召唤且有额外的融合怪兽区域空位）。
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c46232525.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRace(),c)
end
-- 额外卡组融合怪兽的过滤函数：该卡必须是融合怪兽，且其material_race记录了效果所需的种族；该种族需与已送墓素材的种族一致，该卡能被本效果特殊召唤，且特殊召唤时有空余的额外怪兽区域。
function c46232525.spfilter(c,e,tp,race,mc)
	return c:IsType(TYPE_FUSION) and c.material_race and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and race==c.material_race
		-- 检查玩家tp的额外怪兽区域是否有至少1个空格可以特殊召唤该融合怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的条件检测与操作信息设置：检查自己手卡/场上是否存在可送去墓地的素材怪兽，并声明本次效果将进行1次从额外卡组的特殊召唤。
function c46232525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）确认自己的手卡·主要怪兽区存在至少1张满足tgfilter的怪兽卡，即可作为素材且能对应特殊召唤额外融合怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46232525.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本次连锁的处理将进行1次特殊召唤，特殊召唤对象从额外卡组选择（具体卡在处理时确定），用于其他卡的发动判定与时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理流程：选择1张素材怪兽（若在场上里侧表示则先给对方确认），记录其种族后将其送去墓地；确认该素材已在墓地后，从额外卡组选择1只与该种族对应的融合怪兽，中断连锁后将其特殊召唤，并完成特殊召唤手续。
function c46232525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求操作玩家选择1张要作为融合素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
	-- 从自己的手卡和怪兽区域选择1张满足tgfilter的怪兽卡作为融合素材。
	local g=Duel.SelectMatchingCard(tp,c46232525.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 如果选择的素材在场上为里侧表示，则将其翻开给对方玩家确认，以对应效果原文的处理。
		if tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
		local race=tc:GetRace()
		-- 将选中的素材怪兽以效果原因从手卡/场上送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if not tc:IsLocation(LOCATION_GRAVE) then return end
		-- 显示选择提示，要求操作玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1张满足spfilter的融合怪兽，spfilter中通过之前记录的素材种族race来匹配怪兽记述的种族，并确认其可以特殊召唤。
		local sg=Duel.SelectMatchingCard(tp,c46232525.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,race,nil)
		local sc=sg:GetFirst()
		if sc then
			-- 中断当前效果的连锁处理，使后续特殊召唤与之前的送墓处理不视为同时进行，避免造成错误的时点遗漏。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧攻击表示特殊召唤到玩家tp的场上，不检查召唤条件，但仍检查苏生限制。
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
