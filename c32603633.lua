--究極・背水の陣
-- 效果：
-- 把基本分支付到变成100才能发动。自己墓地的名字带有「六武众」的怪兽尽可能特殊召唤。（同名卡最多1张。但是，场上存在的同名卡不能特殊召唤。）
function c32603633.initial_effect(c)
	-- 把基本分支付到变成100才能发动。自己墓地的名字带有「六武众」的怪兽尽可能特殊召唤。（同名卡最多1张。但是，场上存在的同名卡不能特殊召唤。）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32603633.cost)
	e1:SetTarget(c32603633.tg)
	e1:SetOperation(c32603633.op)
	c:RegisterEffect(e1)
end
-- 发动代价函数：把基本分支付到只剩100；若满足则实际支付对应的LP（当前LP-100）作为发动代价。
function c32603633.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取发动玩家当前的LP数值。
	local lp=Duel.GetLP(tp)
	-- 代价检查阶段（chk==0）：判断玩家能否支付“当前LP-100”的LP，即能否把基本分支付到变成100。
	if chk==0 then return Duel.CheckLPCost(tp,lp-100) end
	-- 实际从发动玩家支付（当前LP-100）点LP，使其基本分变为100。
	Duel.PayLPCost(tp,lp-100)
end
-- 特殊召唤候选过滤：墓地中满足“名字带有「六武众」、可以被效果特殊召唤、并且自己场上不存在同名卡”的怪兽。
function c32603633.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外限制：检查场上（双方怪兽区）不存在与此卡同卡名的卡，以符合“场上存在的同名卡不能特殊召唤”。
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetCode())
end
-- 效果发动目标的合法性判定：自己场上必须有可用的主要怪兽区，且墓地中存在至少1只满足特殊召唤条件的「六武众」怪兽。
function c32603633.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域，以确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地中存在至少1只满足过滤条件的「六武众」怪兽；若两者均满足，效果才能发动。
		and Duel.IsExistingMatchingCard(c32603633.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将本次效果的操作信息登记为“从墓地特殊召唤1只怪兽”（用于时点/连锁检测，例如星尘龙等卡的对应）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从自己墓地中按条件选出「六武众」怪兽，尽可能多地特殊召唤（但受场地格子数、青眼精灵龙限制及同名卡限制）。
function c32603633.op(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上当前可用的怪兽区数量，作为最多可特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中所有满足特殊召唤条件的「六武众」怪兽，组成候选集合。
	local g=Duel.GetMatchingGroup(c32603633.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 向操作玩家发送提示消息，要求选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从候选集合中选择1到ft张卡，并通过aux.dncheck保证所选卡名互不相同（对应同名卡最多1张）。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
