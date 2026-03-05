--一色即発
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把最多有对方场上的怪兽数量的4星以下的怪兽从手卡特殊召唤。
function c17509503.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17509503+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c17509503.target)
	e1:SetOperation(c17509503.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤手卡中等级4以下且可以特殊召唤的怪兽
function c17509503.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件
function c17509503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 效果作用：判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c17509503.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁处理信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果原文内容：①：把最多有对方场上的怪兽数量的4星以下的怪兽从手卡特殊召唤。
function c17509503.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 效果作用：获取手卡中满足条件的怪兽数量
	local g=Duel.GetMatchingGroup(c17509503.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 效果作用：计算实际可特殊召唤的怪兽数量
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetCount(),ct)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,ft,nil)
	-- 效果作用：将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
