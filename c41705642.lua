--サルベージ・ウォリアー
-- 效果：
-- 这张卡上级召唤成功时，可以从手卡或者自己墓地把1只调整特殊召唤。
function c41705642.initial_effect(c)
	-- 诱发选发效果，上级召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41705642,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c41705642.spcon)
	e1:SetTarget(c41705642.sptg)
	e1:SetOperation(c41705642.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡为上级召唤成功
function c41705642.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数：满足条件的卡为调整且可特殊召唤
function c41705642.filter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动宣言：选择1只调整特殊召唤
function c41705642.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或墓地是否存在满足条件的调整
		and Duel.IsExistingMatchingCard(c41705642.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：将要特殊召唤1只调整
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理流程：若场上存在空位则选择并特殊召唤调整
function c41705642.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只调整
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c41705642.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的调整特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
