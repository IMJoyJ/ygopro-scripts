--バックリンカー
-- 效果：
-- ①：额外怪兽区域只有对方怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。额外怪兽区域的怪兽全部回到持有者卡组。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c71172240.initial_effect(c)
	-- ①：额外怪兽区域只有对方怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c71172240.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。额外怪兽区域的怪兽全部回到持有者卡组。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71172240,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c71172240.tdcost)
	e2:SetTarget(c71172240.tdtg)
	e2:SetOperation(c71172240.tdop)
	c:RegisterEffect(e2)
end
-- 过滤额外怪兽区域的怪兽（区域索引大于等于5）
function c71172240.filter(c)
	return c:GetSequence()>=5
end
-- 检查手卡特殊召唤的条件是否满足
function c71172240.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方额外怪兽区域是否存在怪兽
		and Duel.IsExistingMatchingCard(c71172240.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己额外怪兽区域是否不存在怪兽
		and not Duel.IsExistingMatchingCard(c71172240.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动代价：解放这张卡
function c71172240.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤额外怪兽区域且可以回到卡组的怪兽
function c71172240.tdfilter(c)
	return c:GetSequence()>=5 and c:IsAbleToDeck()
end
-- 效果②的发动准备（检查并设置操作信息）
function c71172240.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外怪兽区域是否存在可以回到卡组的怪兽（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(c71172240.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取额外怪兽区域中所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(c71172240.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为将这些怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的效果处理（将额外怪兽区域的怪兽送回卡组，并施加额外卡组特召限制）
function c71172240.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前额外怪兽区域中所有可以回到卡组的怪兽
	local g=Duel.GetMatchingGroup(c71172240.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71172240.splimit)
	-- 给玩家注册不能从额外卡组特殊召唤怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特召的怪兽来源为额外卡组
function c71172240.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
