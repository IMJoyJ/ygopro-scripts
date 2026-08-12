--俊足なカバ バリキテリウム
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合发动。对方可以从自己或者对方的墓地选1只4星怪兽在自身场上特殊召唤。
function c7409792.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,7409792+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c7409792.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤成功的场合发动。对方可以从自己或者对方的墓地选1只4星怪兽在自身场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7409792,0))  --"对方特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c7409792.condition)
	e3:SetOperation(c7409792.operation)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件函数：判断自身场上是否有可用的怪兽区域
function c7409792.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自身场上的主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 效果触发条件：判断这张卡是否是通过自身效果（①的方法）特殊召唤成功
function c7409792.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：筛选等级为4且可以特殊召唤的怪兽
function c7409792.filter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：对方可以选择是否从双方墓地特殊召唤1只4星怪兽到自身场上
function c7409792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方墓地中满足条件且不受「王家之谷」影响的4星怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c7409792.filter),1-tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,1-tp)
	-- 判断墓地中是否存在可特殊召唤的怪兽，且对方场上是否有可用的怪兽区域
	if g:GetCount()>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 询问对方玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(1-tp,aux.Stringid(7409792,1)) then  --"是否特殊召唤？"
		-- 提示对方玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 将选择的怪兽以表侧表示特殊召唤到对方场上
		Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
end
end
