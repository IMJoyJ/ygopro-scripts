--バグマンY
-- 效果：
-- 这张卡召唤成功时，自己场上有「漏洞人Z」表侧表示存在的场合，可以从自己卡组把1只「漏洞人X」特殊召唤。
function c23915499.initial_effect(c)
	-- 效果原文内容：这张卡召唤成功时，自己场上有「漏洞人Z」表侧表示存在的场合，可以从自己卡组把1只「漏洞人X」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23915499,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c23915499.condition)
	e1:SetTarget(c23915499.target)
	e1:SetOperation(c23915499.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在表侧表示的「漏洞人Z」
function c23915499.cfilter(c)
	return c:IsFaceup() and c:IsCode(50319138)
end
-- 过滤函数，检查卡组中是否存在可以特殊召唤的「漏洞人X」
function c23915499.spfilter(c,e,tp)
	return c:IsCode(87526784) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果条件函数，判断自己场上是否存在「漏洞人Z」
function c23915499.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张「漏洞人Z」
	return Duel.IsExistingMatchingCard(c23915499.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果目标函数，判断是否满足特殊召唤条件
function c23915499.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可特殊召唤的「漏洞人X」
		and Duel.IsExistingMatchingCard(c23915499.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡为「漏洞人X」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c23915499.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次确认场上是否存在「漏洞人Z」
	if not Duel.IsExistingMatchingCard(c23915499.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 从卡组检索满足条件的「漏洞人X」
	local tc=Duel.GetFirstMatchingCard(c23915499.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的「漏洞人X」特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
