--堕天使の戒壇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把1只「堕天使」怪兽守备表示特殊召唤。
function c14517422.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地把1只「堕天使」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14517422+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14517422.sptg)
	e1:SetOperation(c14517422.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断墓地中的卡是否为「堕天使」怪兽，且该卡能够以表侧守备表示被特殊召唤。
function c14517422.filter(c,e,tp)
	return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的条件检测：自己主要怪兽区有空位，并且墓地存在至少1只满足特殊召唤条件的「堕天使」怪兽。
function c14517422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测墓地中是否存在至少1只满足特殊召唤条件的「堕天使」怪兽。
		and Duel.IsExistingMatchingCard(c14517422.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息：从墓地特殊召唤1只怪兽，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：进行从墓地选择并特殊召唤「堕天使」怪兽的具体操作。
function c14517422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足过滤条件且可被特殊召唤的「堕天使」怪兽。
	local g=Duel.SelectMatchingCard(tp,c14517422.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「堕天使」怪兽以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
