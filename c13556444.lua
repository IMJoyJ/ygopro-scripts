--スターダスト・ミラージュ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有8星以上的龙族同调怪兽存在的场合才能发动。这个回合被战斗或者对方的效果破坏送去自己墓地的怪兽尽可能特殊召唤。
function c13556444.initial_effect(c)
	-- ①：自己场上有8星以上的龙族同调怪兽存在的场合才能发动。这个回合被战斗或者对方的效果破坏送去自己墓地的怪兽尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13556444+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c13556444.spcon)
	e1:SetTarget(c13556444.sptg)
	e1:SetOperation(c13556444.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在8星以上且为龙族的同调怪兽
function c13556444.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 效果发动的条件判断函数
function c13556444.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c13556444.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选可以特殊召唤的墓地怪兽
function c13556444.spfilter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsReason(REASON_DESTROY)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果的发动目标设定函数
function c13556444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c13556444.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的卡牌来源为墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果的发动处理函数
function c13556444.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足特殊召唤条件的墓地怪兽组
	local tg=Duel.GetMatchingGroup(c13556444.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
	if ft<1 or #tg<1 then return end
	-- 若自己受到效果影响（如王家长眠之谷），则限制召唤数量为1
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家提示选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=tg:Select(tp,ft,ft,nil)
	-- 执行特殊召唤操作，将选中的卡牌正面表示特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
