--双星神 a－vida
-- 效果：
-- 这张卡不能通常召唤。双方的场上·墓地有连接怪兽8种类以上存在的场合才能特殊召唤。把这张卡特殊召唤的回合，自己不能把其他怪兽特殊召唤。
-- ①：这张卡的特殊召唤不会被无效化。
-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的双方的场上·墓地的怪兽以及除外中的怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
function c17469113.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。双方的场上·墓地有连接怪兽8种类以上存在的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17469113.sprcon)
	c:RegisterEffect(e1)
	-- ①：这张卡的特殊召唤不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- 把这张卡特殊召唤的回合，自己不能把其他怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_SPSUMMON_COST)
	e4:SetCost(c17469113.spcost)
	e4:SetOperation(c17469113.spop)
	c:RegisterEffect(e4)
	-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的双方的场上·墓地的怪兽以及除外中的怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17469113,0))
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetTarget(c17469113.tdtg)
	e5:SetOperation(c17469113.tdop)
	c:RegisterEffect(e5)
end
-- 筛选出双方场上表侧表示或墓地中的连接怪兽，用于统计连接怪兽的种类数。
function c17469113.sprfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_LINK)
end
-- 特殊召唤条件判定：双方场上·墓地存在8种以上连接怪兽，且自己主要怪兽区有空位时才可特殊召唤。
function c17469113.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上·墓地中所有满足条件的连接怪兽的集合（用于统计种类数）。
	local g=Duel.GetMatchingGroup(c17469113.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	return g:GetClassCount(Card.GetCode)>=8
		-- 检查自己主要怪兽区是否有可用空格，确保特殊召唤成功时有位置可放置。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 特殊召唤代价判定：本回合自己尚未进行过特殊召唤，即这张卡必须是本回合第一次特殊召唤的怪兽。
function c17469113.spcost(e,c,tp)
	-- 获取本回合自己进行过的特殊召唤次数，要求为0（保证这张卡是本回合第一只特殊召唤的怪兽）。
	return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
end
-- 为控制者施加本回合的誓约限制：特殊召唤成功后，自己不能再特殊召唤其他怪兽（持续到结束阶段）。
function c17469113.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 把这张卡特殊召唤的回合，自己不能把其他怪兽特殊召唤。②：这张卡特殊召唤成功的场合发动。这张卡以外的双方的场上·墓地的怪兽以及除外中的怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17469113.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止特殊召唤的限制效果注册给当前玩家，使其在本回合内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数：除了这张卡自身以外的怪兽都不能被特殊召唤。
function c17469113.splimit(e,c,tp,sumtp,sumpos)
	return c~=e:GetHandler()
end
-- 筛选②效果的对象：场上·墓地以及表侧除外中的怪兽，且满足可返回卡组条件。
function c17469113.tdfilter(c)
	return (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end
-- ②效果发动时的目标处理：设定回卡组的效果信息，并禁止对方连锁魔法·陷阱·怪兽效果。
function c17469113.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取这张卡以外双方场上·墓地及表侧除外中的可回卡组怪兽集合。
	local g=Duel.GetMatchingGroup(c17469113.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler())
	-- 设置操作信息：将上述对象组标记为本次效果将返回卡组的卡片，供其他卡响应检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置连锁限制为始终不能连锁，对应“不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动”。
	Duel.SetChainLimit(aux.FALSE)
end
-- 效果处理：将对象怪兽全部洗回持有者卡组；若受王家长眠之谷等影响则处理无效。
function c17469113.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取符合条件的对象组，并排除仍与效果相关的这张卡。
	local g=Duel.GetMatchingGroup(c17469113.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,aux.ExceptThisCard(e))
	-- 检查对象是否受到王家长眠之谷等效果影响，若存在且连锁可被无效，则终止本次回卡组处理。
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将所有对象怪兽以洗牌方式送回持有者卡组。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
