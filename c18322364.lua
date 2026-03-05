--ビッグ・ホエール
-- 效果：
-- 这张卡上级召唤成功时，把这张卡解放才能发动。从卡组把3只3星的水属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c18322364.initial_effect(c)
	-- 效果原文：这张卡上级召唤成功时，把这张卡解放才能发动。从卡组把3只3星的水属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18322364,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c18322364.condition)
	e1:SetCost(c18322364.cost)
	e1:SetTarget(c18322364.target)
	e1:SetOperation(c18322364.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断此卡是否为上级召唤成功
function c18322364.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果作用：支付解放此卡的代价
function c18322364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 效果作用：将此卡解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果作用：定义特殊召唤的怪兽必须满足的条件（3星水属性）
function c18322364.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件（未受青眼精灵龙影响、场上空间足够、卡组有3只符合条件怪兽）
function c18322364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果作用：判断场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 效果作用：判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c18322364.spfilter,tp,LOCATION_DECK,0,3,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤并使召唤的怪兽效果无效
function c18322364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 效果作用：获取卡组中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c18322364.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<3 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,3,3,nil)
	local tc=sg:GetFirst()
	while tc do
		-- 效果作用：将一张怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 效果原文：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=sg:GetNext()
	end
	-- 效果作用：完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
