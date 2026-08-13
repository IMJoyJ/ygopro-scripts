--ニコイチ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己墓地把1只机械族·暗属性怪兽除外才能发动。把有「马达衍生物」的衍生物名记述的1只怪兽从自己的手卡·卡组·墓地特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的机械族·暗属性怪兽被战斗以外送去墓地的场合，把这张卡除外才能发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
local s,id,o=GetID()
-- 定义初始效果函数，为本卡注册两个效果：e1对应①效果的魔法卡发动效果，e2对应②效果的墓地诱发效果；两者共用1回合1次的限制（通过SetCountLimit(1,id)实现）。
function s.initial_effect(c)
	-- 将马达衍生物（卡号82556059）登记为本卡卡名记述的卡，用于后续检索“有「马达衍生物」的衍生物名记述的怪兽”。
	aux.AddCodeList(c,82556059)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从自己墓地把1只机械族·暗属性怪兽除外才能发动。把有「马达衍生物」的衍生物名记述的1只怪兽从自己的手卡·卡组·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡在墓地存在的状态，自己场上的表侧表示的机械族·暗属性怪兽被战斗以外送去墓地的场合，把这张卡除外才能发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 设置②效果的发动代价为把自身从墓地除外（由aux.bfgcost实现，对应原文“把这张卡除外才能发动”）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义①代价的筛选函数：从自己墓地选择1只机械族·暗属性怪兽作为除外代价，且在手卡·卡组·墓地存在可特殊召唤的“马达衍生物”记述怪兽，确保发动后有效果处理。
function s.cfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
		-- 在筛选代价怪兽时，额外要求手卡·卡组·墓地存在至少1只满足s.spfilter的可特殊召唤怪兽，且该怪兽不能是当前候选代价怪兽（ex=c），避免同一张卡既被除外又被特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 定义①效果的代价：检测到满足条件后，从自己墓地选择1只机械族·暗属性怪兽表侧表示除外作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认墓地存在至少1张满足s.cfilter的卡（可作为代价且另有可特召对象），否则不能发动①。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 发送选择提示，提示玩家从墓地选择要除外的机械族·暗属性怪兽（文本为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张满足s.cfilter的机械族·暗属性怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧表示除外（这是①效果的发动代价）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义①效果要特殊召唤的怪兽的筛选函数：卡名或效果文本中记载了「马达衍生物」且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	-- 过滤条件：该怪兽的卡名/效果文本中记述了马达衍生物（卡号82556059），并且可以被本次效果特殊召唤（以通常的召唤条件/苏生限制进行判定）。
	return aux.IsCodeListed(c,82556059) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果的发动目标：检查自己主要怪兽区有空位，且手卡·卡组·墓地存在可特殊召唤的“马达衍生物”记述怪兽，满足条件则允许发动并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己主要怪兽区有空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检测：确认手卡·卡组·墓地存在至少1只满足s.spfilter的可特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次特殊召唤不取对象，预计从手卡·卡组·墓地特殊召唤1只怪兽（供连锁检测和效果发动判定使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义①效果处理：若主要怪兽区仍有空位，则从手卡·卡组·墓地选择1只满足条件且不受王家长眠之谷影响的怪兽表侧攻击表示特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送“请选择要特殊召唤的卡”的提示，供玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·卡组·墓地选择1只满足s.spfilter且不受王家长眠之谷影响的怪兽（使用aux.NecroValleyFilter过滤掉墓地受王谷限制不能特召的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件和苏生限制，因为s.spfilter已判定）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果触发事件的过滤条件：被送去墓地的怪兽必须在此之前是自己场上表侧表示、机械族·暗属性、且不是因战斗被破坏。
function s.cspfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_DARK)~=0
		and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_BATTLE)
end
-- 定义②效果的触发条件：本次被送去墓地的怪兽集合中存在满足s.cspfilter条件的怪兽，即自己场上表侧表示的机械族·暗属性怪兽被战斗以外的方式送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cspfilter,1,nil,tp)
end
-- 定义②效果的发动目标判定：自己主要怪兽区有空位，且可以特殊召唤1只「马达衍生物」token（机械族·地·1星·攻/守200攻击表示），满足条件则设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 目标检测：确认自己主要怪兽区有空位，用于放置「马达衍生物」token。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 目标检测：确认自己可以特殊召唤1只「马达衍生物」token（参数：机械族、地属性、1星、攻200/守200、攻击表示），token类型为衍生物怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK,tp,0) end
	-- 设置操作信息：本次效果将特殊召唤1只不取对象的怪兽（targets=nil，count=1），用于连锁反应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：本次效果还会产生衍生物（CATEGORY_TOKEN），使相关触发效果可以正确检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- 定义②效果处理：若仍可以特召「马达衍生物」token，则创建token并表侧攻击表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认可以特殊召唤该token，防止处理时场地空位不足或状态变化导致不能特召。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK,tp,0) then
		-- 创建1只「马达衍生物」token，卡号使用id+o（脚本内定义的token卡号）。
		local token=Duel.CreateToken(tp,id+o)
		-- 将创建的「马达衍生物」token以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
