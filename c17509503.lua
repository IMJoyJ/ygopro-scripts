--一色即発
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把最多有对方场上的怪兽数量的4星以下的怪兽从手卡特殊召唤。
function c17509503.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把最多有对方场上的怪兽数量的4星以下的怪兽从手卡特殊召唤。
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
-- 过滤函数：筛选手卡中满足等级4以下且能够被特殊召唤的怪兽。
function c17509503.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标判定函数：在发动时（chk==0）确认自己场上有空位、对方场上有怪兽，并且手卡存在至少1只可特殊召唤的4星以下怪兽，否则不能发动。
function c17509503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己主要怪兽区有空位，且对方场上有怪兽（作为可特殊召唤数量的参照）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 发动条件之二：手卡中存在至少1只满足过滤条件（4星以下且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c17509503.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果包含特殊召唤，预定从手卡特殊召唤；数量暂记至少1只，实际数量在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：计算可特殊召唤数量，让玩家从手卡选择1至该数量的4星以下怪兽进行特殊召唤；若受青眼精灵龙效果影响，则最多只能特殊召唤1只。
function c17509503.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的怪兽数量，作为可特殊召唤数量的上限参考。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 获取手卡中所有满足特殊召唤条件的4星以下怪兽。
	local g=Duel.GetMatchingGroup(c17509503.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 计算实际可特殊召唤数量：取自己主要怪兽区空位数、可用手卡怪兽数、对方场上怪兽数三者的最小值。
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetCount(),ct)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家弹出选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,ft,nil)
	-- 将玩家选中的怪兽以表侧表示特殊召唤到自己场上（不忽略召唤条件和苏生限制）。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
