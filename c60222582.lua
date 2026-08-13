--銀河遠征
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有5星以上的，「光子」怪兽或「银河」怪兽存在的场合才能发动。从卡组把5星以上的1只「光子」怪兽或「银河」怪兽守备表示特殊召唤。
function c60222582.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有5星以上的，「光子」怪兽或「银河」怪兽存在的场合才能发动。从卡组把5星以上的1只「光子」怪兽或「银河」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,60222582+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c60222582.condition)
	e1:SetTarget(c60222582.target)
	e1:SetOperation(c60222582.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示、等级5以上、且属于「光子」或「银河」系列。
function c60222582.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSetCard(0x55,0x7b)
end
-- 效果发动条件判定：检查自己场上是否存在至少1只满足过滤条件的「光子」或「银河」怪兽。
function c60222582.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示、等级5以上且属于「光子」或「银河」系列的怪兽。
	return Duel.IsExistingMatchingCard(c60222582.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特召候选过滤函数：判断卡组中的卡是否等级5以上、属于「光子」或「银河」系列，并且能够被以表侧守备表示特殊召唤。
function c60222582.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x55,0x7b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- target函数：在发动时检查自己主要怪兽区是否有空位，以及卡组中是否存在能特殊召唤的符合条件的怪兽。
function c60222582.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若是发动确认阶段（chk==0），首先检查自己的主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足spfilter过滤条件的怪兽，作为发动的前提。
		and Duel.IsExistingMatchingCard(c60222582.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果操作信息设置为特殊召唤卡组中的1只怪兽，用于连锁处理和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：实际执行特殊召唤——选择卡组中1只符合条件的「光子」或「银河」怪兽，以表侧守备表示特殊召唤到自己场上。
function c60222582.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若主要怪兽区没有空位，则直接终止效果处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发出提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足spfilter过滤条件的怪兽（不取对象，由玩家在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c60222582.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上（检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
