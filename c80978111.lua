--飛翔するG
-- 效果：
-- 对方对怪兽的召唤·特殊召唤成功时，这张卡可以从手卡往对方场上表侧守备表示特殊召唤。只要这张卡在场上表侧表示存在，这张卡的控制者不能超量召唤。
function c80978111.initial_effect(c)
	-- 对方对怪兽的召唤·特殊召唤成功时，这张卡可以从手卡往对方场上表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80978111,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c80978111.condition)
	e1:SetTarget(c80978111.target)
	e1:SetOperation(c80978111.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，这张卡的控制者不能超量召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c80978111.splimit)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查怪兽是否由指定玩家召唤或特殊召唤
function c80978111.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断召唤、特殊召唤成功的怪兽中是否存在由对方玩家召唤的怪兽
function c80978111.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c80978111.cfilter,1,nil,1-tp)
end
-- 效果发动的目标，检查对方场上是否有可用怪兽区域，且自身能否在对方场上特殊召唤
function c80978111.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，将自身特殊召唤到对方场上
function c80978111.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且对方场上仍有可用怪兽区域
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 then
		-- 将此卡以表侧守备表示特殊召唤到对方场上
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 限制特殊召唤的类型为超量召唤
function c80978111.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ
end
