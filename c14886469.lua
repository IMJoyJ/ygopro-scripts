--レッド・スプリンター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤时，若自己场上没有其他怪兽存在则能发动。从自己的手卡·墓地把1只3星以下的恶魔族调整特殊召唤。
function c14886469.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·特殊召唤时，若自己场上没有其他怪兽存在则能发动。从自己的手卡·墓地把1只3星以下的恶魔族调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14886469,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,14886469)
	e1:SetCondition(c14886469.spcon)
	e1:SetTarget(c14886469.sptg)
	e1:SetOperation(c14886469.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果作用：判断场上是否没有其他怪兽存在
function c14886469.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查自己场上是否存在其他怪兽
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果作用：定义满足条件的卡片过滤函数
function c14886469.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置发动时的处理目标
function c14886469.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查手卡或墓地是否存在符合条件的卡片
		and Duel.IsExistingMatchingCard(c14886469.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁处理信息，确定将要特殊召唤的卡片来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果作用：设置效果发动时的具体处理流程
function c14886469.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否还有怪兽区域可用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 规则层面操作：选择满足条件的1只恶魔族调整
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c14886469.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
