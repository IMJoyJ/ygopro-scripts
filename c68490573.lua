--大いなる魂
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有龙族同调怪兽存在的场合才能发动。从卡组把「共鸣者」怪兽或龙族·1星怪兽合计最多2只特殊召唤。
-- ②：自己场上有10星以上的龙族·暗属性同调怪兽存在，怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效，自己场上1只同调怪兽的攻击力直到下个回合的结束时上升2000。
function c68490573.initial_effect(c)
	-- ①：场上有龙族同调怪兽存在的场合才能发动。从卡组把「共鸣者」怪兽或龙族·1星怪兽合计最多2只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,68490573)
	e1:SetCondition(c68490573.condition)
	e1:SetTarget(c68490573.target)
	e1:SetOperation(c68490573.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有10星以上的龙族·暗属性同调怪兽存在，怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效，自己场上1只同调怪兽的攻击力直到下个回合的结束时上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,68490574)
	e2:SetCondition(c68490573.discon)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68490573.distg)
	e2:SetOperation(c68490573.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的龙族同调怪兽
function c68490573.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果①的发动条件：场上有龙族同调怪兽存在
function c68490573.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的龙族同调怪兽
	return Duel.IsExistingMatchingCard(c68490573.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤条件：卡组中可以特殊召唤的「共鸣者」怪兽或龙族·1星怪兽
function c68490573.spfilter(c,e,tp)
	return (c:IsSetCard(0x57) or c:IsRace(RACE_DRAGON) and c:IsLevel(1)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽
function c68490573.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c68490573.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组特殊召唤最多2只满足条件的怪兽
function c68490573.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择最多2只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c68490573.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的10星以上的龙族·暗属性同调怪兽
function c68490573.disfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(10) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上有10星以上的龙族·暗属性同调怪兽存在，且有怪兽效果发动
function c68490573.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的10星以上的龙族·暗属性同调怪兽
	return Duel.IsExistingMatchingCard(c68490573.disfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果，且该效果可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果②的发动准备：设置无效效果的操作信息
function c68490573.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息：使发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 过滤条件：自己场上表侧表示的同调怪兽
function c68490573.atkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 效果②的效果处理：使效果无效，并让己方1只同调怪兽攻击力上升2000
function c68490573.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的同调怪兽
	local g=Duel.GetMatchingGroup(c68490573.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 如果成功无效该效果，且自己场上存在同调怪兽
	if Duel.NegateEffect(ev) and g:GetCount()>0 then
		-- 提示玩家选择要上升攻击力的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(68490573,2))  --"请选择要上升攻击力的怪兽"
		local tg=g:Select(tp,1,1,nil)
		-- 在场上显式框选被选中的怪兽
		Duel.HintSelection(tg)
		-- 自己场上1只同调怪兽的攻击力直到下个回合的结束时上升2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tg:GetFirst():RegisterEffect(e1)
	end
end
