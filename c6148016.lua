--ギアギアギア
-- 效果：
-- 从卡组把2只名字带有「齿轮齿轮人」的怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升1星。「齿轮齿轮齿轮」在1回合只能发动1张。
function c6148016.initial_effect(c)
	-- 从卡组把2只名字带有「齿轮齿轮人」的怪兽特殊召唤。这个效果特殊召唤的怪兽的等级上升1星。「齿轮齿轮齿轮」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,6148016+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c6148016.sptg)
	e1:SetOperation(c6148016.spop)
	c:RegisterEffect(e1)
end
-- 过滤卡组中名字带有「齿轮齿轮人」且可以特殊召唤的怪兽
function c6148016.filter(c,e,tp)
	return c:IsSetCard(0x1072) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检测（检查青眼精灵龙的影响、己方主要怪兽区域空位数以及卡组中是否存在2只可特殊召唤的「齿轮齿轮人」怪兽）
function c6148016.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c6148016.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果会从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑（特殊召唤2只怪兽并使其等级上升1星）
function c6148016.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若己方主要怪兽区域的空位数不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足过滤条件的「齿轮齿轮人」怪兽
	local g=Duel.GetMatchingGroup(c6148016.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将选择的第一只怪兽以表侧表示特殊召唤（分解步骤）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
		-- 将选择的第二只怪兽以表侧表示特殊召唤（分解步骤）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
