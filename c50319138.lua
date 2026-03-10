--バグマンZ
-- 效果：
-- 这张卡召唤成功时，自己场上有「漏洞人X」表侧表示存在的场合，可以从自己卡组把1只「漏洞人Y」特殊召唤。
function c50319138.initial_effect(c)
	-- 效果原文内容：这张卡召唤成功时，自己场上有「漏洞人X」表侧表示存在的场合，可以从自己卡组把1只「漏洞人Y」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50319138,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c50319138.condition)
	e1:SetTarget(c50319138.target)
	e1:SetOperation(c50319138.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，用于判断场上是否存在表侧表示的「漏洞人X」
function c50319138.cfilter(c)
	return c:IsFaceup() and c:IsCode(87526784)
end
-- 检索满足条件的卡片组，用于判断卡组中是否存在可以特殊召唤的「漏洞人Y」
function c50319138.spfilter(c,e,tp)
	return c:IsCode(23915499) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断自己场上有「漏洞人X」表侧表示存在
function c50319138.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己场上有「漏洞人X」表侧表示存在的场合
	return Duel.IsExistingMatchingCard(c50319138.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果作用：设置发动时的条件检查，确保满足特殊召唤的条件
function c50319138.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断自己卡组中是否存在满足条件的「漏洞人Y」
		and Duel.IsExistingMatchingCard(c50319138.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，用于记录将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作
function c50319138.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：再次确认自己场上有「漏洞人X」表侧表示存在
	if not Duel.IsExistingMatchingCard(c50319138.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 检索满足条件的卡片组，获取卡组中第一张符合条件的「漏洞人Y」
	local tc=Duel.GetFirstMatchingCard(c50319138.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
