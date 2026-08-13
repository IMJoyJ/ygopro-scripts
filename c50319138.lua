--バグマンZ
-- 效果：
-- 这张卡召唤成功时，自己场上有「漏洞人X」表侧表示存在的场合，可以从自己卡组把1只「漏洞人Y」特殊召唤。
function c50319138.initial_effect(c)
	-- 这张卡召唤成功时，自己场上有「漏洞人X」表侧表示存在的场合，可以从自己卡组把1只「漏洞人Y」特殊召唤。
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
-- 定义过滤器cfilter：判断卡片是否为表侧表示且卡号为87526784（「漏洞人X」），用于确认自己场上是否存在满足条件的「漏洞人X」。
function c50319138.cfilter(c)
	return c:IsFaceup() and c:IsCode(87526784)
end
-- 定义特殊召唤过滤器spfilter：判断卡片是否为卡号23915499（「漏洞人Y」），且能否被当前效果以通常方式特殊召唤。
function c50319138.spfilter(c,e,tp)
	return c:IsCode(23915499) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件：检查自己场上是否存在至少1张表侧表示的「漏洞人X」，满足时效果才能发动。
function c50319138.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查：从自己场上（LOCATION_ONFIELD）检索是否存在1张以上满足cfilter的表侧表示「漏洞人X」。
	return Duel.IsExistingMatchingCard(c50319138.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动时的目标判定：确认自己主要怪兽区有空位，且卡组中存在可以特殊召唤的「漏洞人Y」，满足才可发动。
function c50319138.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己主要怪兽区是否有空余区域可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查：卡组中是否存在至少1张满足spfilter条件、可以特殊召唤的「漏洞人Y」。
		and Duel.IsExistingMatchingCard(c50319138.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：告知系统本效果将在处理时从卡组特殊召唤1只怪兽（数量1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：若场上仍有空位且仍存在表侧表示「漏洞人X」，则从卡组选1只「漏洞人Y」特殊召唤到场上。
function c50319138.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时复核：若自己主要怪兽区没有空位，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时复核：若自己场上已没有表侧表示的「漏洞人X」，则终止处理。
	if not Duel.IsExistingMatchingCard(c50319138.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	-- 从卡组中获取第一张满足spfilter的卡，即可以特殊召唤的「漏洞人Y」。
	local tc=Duel.GetFirstMatchingCard(c50319138.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将选中的「漏洞人Y」以表侧表示形式特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
