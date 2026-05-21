--バグマンX
-- 效果：
-- 这张卡召唤成功时，自己场上有「漏洞人Y」表侧表示存在的场合，可以从自己卡组把1只「漏洞人Z」特殊召唤。
function c87526784.initial_effect(c)
	-- 这张卡召唤成功时，自己场上有「漏洞人Y」表侧表示存在的场合，可以从自己卡组把1只「漏洞人Z」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87526784,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c87526784.condition)
	e1:SetTarget(c87526784.target)
	e1:SetOperation(c87526784.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「漏洞人Y」
function c87526784.cfilter(c)
	return c:IsFaceup() and c:IsCode(23915499)
end
-- 过滤条件：卡组中可以特殊召唤的「漏洞人Z」
function c87526784.spfilter(c,e,tp)
	return c:IsCode(50319138) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件：自己场上存在表侧表示的「漏洞人Y」
function c87526784.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「漏洞人Y」
	return Duel.IsExistingMatchingCard(c87526784.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动目标：检查怪兽区域空位以及卡组中是否存在可特殊召唤的「漏洞人Z」
function c87526784.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检查可行性阶段，则检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1只可以特殊召唤的「漏洞人Z」
		and Duel.IsExistingMatchingCard(c87526784.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只「漏洞人Z」特殊召唤
function c87526784.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若此时自己场上不存在表侧表示的「漏洞人Y」，则不处理效果
	if not Duel.IsExistingMatchingCard(c87526784.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 获取卡组中第一张满足条件的「漏洞人Z」
	local tc=Duel.GetFirstMatchingCard(c87526784.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将该怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
