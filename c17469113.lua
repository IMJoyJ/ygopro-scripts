--双星神 a－vida
-- 效果：
-- 这张卡不能通常召唤。双方的场上·墓地有连接怪兽8种类以上存在的场合才能特殊召唤。把这张卡特殊召唤的回合，自己不能把其他怪兽特殊召唤。
-- ①：这张卡的特殊召唤不会被无效化。
-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的双方的场上·墓地的怪兽以及除外中的怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
function c17469113.initial_effect(c)
	c:EnableReviveLimit()
	-- 双方的场上·墓地有连接怪兽8种类以上存在的场合才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17469113.sprcon)
	c:RegisterEffect(e1)
	-- 这张卡的特殊召唤不会被无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e2)
	-- 把这张卡特殊召唤的回合，自己不能把其他怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- 把这张卡特殊召唤的回合，自己不能把其他怪兽特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_SPSUMMON_COST)
	e4:SetCost(c17469113.spcost)
	e4:SetOperation(c17469113.spop)
	c:RegisterEffect(e4)
	-- 这张卡特殊召唤成功的场合发动。这张卡以外的双方的场上·墓地的怪兽以及除外中的怪兽全部回到持有者卡组。不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(17469113,0))
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetTarget(c17469113.tdtg)
	e5:SetOperation(c17469113.tdop)
	c:RegisterEffect(e5)
end
-- 用于筛选场上或墓地的连接怪兽
function c17469113.sprfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_LINK)
end
-- 判断是否满足特殊召唤条件，即双方场上或墓地的连接怪兽数量达到8种且有空位
function c17469113.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上和墓地的连接怪兽组
	local g=Duel.GetMatchingGroup(c17469113.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	return g:GetClassCount(Card.GetCode)>=8
		-- 判断是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 检查该回合是否已经进行过特殊召唤
function c17469113.spcost(e,c,tp)
	-- 检查该回合是否已经进行过特殊召唤
	return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
end
-- 创建并注册一个回合结束时失效的不能特殊召唤效果
function c17469113.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 不能特殊召唤除自身外的其他怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17469113.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 不能特殊召唤除自身外的其他怪兽
function c17469113.splimit(e,c,tp,sumtp,sumpos)
	return c~=e:GetHandler()
end
-- 用于筛选可以送回卡组的怪兽
function c17469113.tdfilter(c)
	return (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end
-- 设置连锁处理信息，确定要送回卡组的怪兽
function c17469113.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取所有符合条件的怪兽组
	local g=Duel.GetMatchingGroup(c17469113.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler())
	-- 设置连锁处理信息，确定要送回卡组的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	-- 设置连锁限制为无效
	Duel.SetChainLimit(aux.FALSE)
end
-- 执行将怪兽送回卡组的操作
function c17469113.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有符合条件的怪兽组
	local g=Duel.GetMatchingGroup(c17469113.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,aux.ExceptThisCard(e))
	-- 检查是否被王家长眠之谷保护
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将怪兽送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
