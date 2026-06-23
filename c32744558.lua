--レアル・ジェネクス・コーディネイター
-- 效果：
-- ①：这张卡召唤·特殊召唤时才能发动。从手卡把1只3星以下的「次世代」怪兽特殊召唤。
function c32744558.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤时才能发动。
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
-- 过滤函数，用于筛选手卡中满足条件的「次世代」怪兽
function c32744558.filter(c,e,tp)
	return c:IsSetCard(0x2) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c32744558.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只3星以下的「次世代」怪兽
		and Duel.IsExistingMatchingCard(c32744558.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c32744558.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c32744558.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
