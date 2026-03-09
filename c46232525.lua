--ヘルモスの爪
-- 效果：
-- 这张卡的卡名在规则上也当作「传说之龙 赫谟」使用。「赫谟之爪」在1回合只能发动1张。
-- ①：「赫谟之爪」的效果才能特殊召唤的融合怪兽卡记述的种族的1只怪兽从自己的手卡·场上送去墓地（那张卡在场上盖放的场合，翻开确认）。那之后，把那1只融合怪兽从额外卡组特殊召唤。
function c46232525.initial_effect(c)
	-- 效果原文内容：「赫谟之爪」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46232525+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46232525.target)
	e1:SetOperation(c46232525.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡的卡名在规则上也当作「传说之龙 赫谟」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(10000070)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查以玩家tp来看的手牌或场上的怪兽中是否存在满足条件的卡片（即该怪兽为怪兽卡且其种族能对应额外卡组中融合怪兽的种族）
function c46232525.tgfilter(c,e,tp)
	-- 返回值为true表示该怪兽是怪兽卡并且在额外卡组中存在以该怪兽种族为融合素材的融合怪兽
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c46232525.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRace(),c)
end
-- 过滤函数，检查以玩家tp来看的额外卡组中是否存在满足条件的融合怪兽（即该融合怪兽为融合怪兽且其material_race字段存在、能特殊召唤、种族匹配且场上空位足够）
function c46232525.spfilter(c,e,tp,race,mc)
	return c:IsType(TYPE_FUSION) and c.material_race and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and race==c.material_race
		-- 返回值大于0表示在目标玩家场上存在足够的位置用于特殊召唤该融合怪兽
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果处理时的判断函数，检查以玩家tp来看的手牌或场上的怪兽中是否存在至少1张满足条件的卡片
function c46232525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未进行过判定，则检查是否存在满足条件的卡片（即手牌或场上的怪兽为怪兽卡且其种族能对应额外卡组中融合怪兽的种族）
	if chk==0 then return Duel.IsExistingMatchingCard(c46232525.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置操作信息，表示本次连锁将处理特殊召唤1张来自额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时的处理函数，用于选择融合素材并执行后续特殊召唤流程
function c46232525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择作为融合素材的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
	-- 让玩家tp从手牌或场上选择1张满足条件的卡片作为融合素材
	local g=Duel.SelectMatchingCard(tp,c46232525.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 若该卡片在场且为里侧表示，则翻开确认其内容
		if tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
		local race=tc:GetRace()
		-- 将所选卡片送去墓地，作为特殊召唤的代价
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if not tc:IsLocation(LOCATION_GRAVE) then return end
		-- 提示玩家选择要从额外卡组特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家tp从额外卡组中选择1张满足条件的融合怪兽
		local sg=Duel.SelectMatchingCard(tp,c46232525.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,race,nil)
		local sc=sg:GetFirst()
		if sc then
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 将所选的融合怪兽以正面表示的形式特殊召唤到玩家tp场上
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
