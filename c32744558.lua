--レアル・ジェネクス・コーディネイター
-- 效果：
-- ①：这张卡召唤·特殊召唤时才能发动。从手卡把1只3星以下的「次世代」怪兽特殊召唤。
function c32744558.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤时才能发动。从手卡把1只3星以下的「次世代」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32744558,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c32744558.target)
	e1:SetOperation(c32744558.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：从手卡中选出1只3星以下、卡名含有「次世代」字段且能够被特殊召唤的怪兽。
function c32744558.filter(c,e,tp)
	return c:IsSetCard(0x2) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法判定：确认自己场上有空位，且手卡中存在至少1只满足筛选条件的「次世代」怪兽。
function c32744558.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足c32744558.filter条件的「次世代」怪兽。
		and Duel.IsExistingMatchingCard(c32744558.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：将从手卡特殊召唤1只怪兽，特殊召唤的对象数量为1，持有者为自己，位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理流程：再次确认有可用怪兽区后，让玩家从手卡选择1只符合条件的「次世代」怪兽，并以表侧表示特殊召唤到自己场上。
function c32744558.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己主要怪兽区是否仍有空格，如果没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1张满足c32744558.filter条件的「次世代」怪兽（必须选1张）。
	local g=Duel.SelectMatchingCard(tp,c32744558.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（按正常规则检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
