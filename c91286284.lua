--GP－アウト・オブ・ノーウェア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把1只「黄金荣耀」怪兽特殊召唤。那之后，对方可以从自身的手卡·墓地把1只怪兽效果无效在自身场上特殊召唤。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地把1只「黄金荣耀」怪兽特殊召唤。那之后，对方可以从自身的手卡·墓地把1只怪兽效果无效在自身场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤自身手卡·墓地中可以特殊召唤的「黄金荣耀」怪兽。
function s.filter(c,e,tp)
	return c:IsSetCard(0x192) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的检测与处理（Target函数）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在可以特殊召唤的「黄金荣耀」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果发动的具体处理逻辑（Operation函数）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示自己选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选出自己手卡·墓地1只满足条件的「黄金荣耀」怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 获取对方手卡·墓地中所有可以特殊召唤的怪兽（受王家之谷影响）。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,0,LOCATION_GRAVE+LOCATION_HAND,nil,e,0,1-tp,false,false)
	-- 成功将选中的「黄金荣耀」怪兽在自己场上表侧表示特殊召唤。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查对方场上是否有可用的怪兽区域，且对方手卡·墓地有可特殊召唤的怪兽。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #tg>0
		-- 询问对方是否选择特殊召唤怪兽。
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否选怪兽特殊召唤？"
		-- 提示对方选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=tg:Select(1-tp,1,1,nil):GetFirst()
		-- 中断当前效果，使后续的特殊召唤处理视为不同时处理。
		Duel.BreakEffect()
		-- 尝试将对方选中的怪兽在对方场上表侧表示特殊召唤。
		if Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP) then
			-- 效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的最终处理。
		Duel.SpecialSummonComplete()
	end
end
