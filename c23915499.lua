--バグマンY
-- 效果：
-- 这张卡召唤成功时，自己场上有「漏洞人Z」表侧表示存在的场合，可以从自己卡组把1只「漏洞人X」特殊召唤。
function c23915499.initial_effect(c)
	-- 这张卡召唤成功时，自己场上有「漏洞人Z」表侧表示存在的场合，可以从自己卡组把1只「漏洞人X」特殊召唤。
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
-- 定义过滤条件：卡必须为表侧表示，且卡名是「漏洞人Z」（卡号50319138）。
function c23915499.cfilter(c)
	return c:IsFaceup() and c:IsCode(50319138)
end
-- 定义特殊召唤候选的过滤条件：卡名是「漏洞人X」（卡号87526784），并且可以被当前效果以通常方式特殊召唤。
function c23915499.spfilter(c,e,tp)
	return c:IsCode(87526784) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判断：检查自己场上是否存在表侧表示的「漏洞人Z」。
function c23915499.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查自己场上是否存在至少1张满足cfilter条件（表侧表示的「漏洞人Z」）的卡。
	return Duel.IsExistingMatchingCard(c23915499.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动时的目标合法性判断：自己的主要怪兽区域有空位，且卡组中存在可以特殊召唤的「漏洞人X」。
function c23915499.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区域有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时确认卡组中存在满足spfilter的「漏洞人X」可以作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c23915499.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果处理信息设置为：从卡组特殊召唤1只怪兽（用于连锁/时点判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际执行：在仍有空位且场上仍有表侧表示「漏洞人Z」时，从卡组选择1只「漏洞人X」特殊召唤。
function c23915499.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认主要怪兽区域有空位，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理前再次确认自己场上仍有表侧表示的「漏洞人Z」，否则终止处理。
	if not Duel.IsExistingMatchingCard(c23915499.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 从卡组中选取符合spfilter的第一张卡，即「漏洞人X」。
	local tc=Duel.GetFirstMatchingCard(c23915499.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将选取的「漏洞人X」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
