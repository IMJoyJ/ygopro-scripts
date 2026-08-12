--ドライトロン流星群
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有仪式怪兽存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽回到持有者卡组。
function c84965420.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有仪式怪兽存在，对方把怪兽召唤·特殊召唤之际才能发动。那个无效，那些怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCountLimit(1,84965420+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c84965420.condition)
	e1:SetTarget(c84965420.target)
	e1:SetOperation(c84965420.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的仪式怪兽
function c84965420.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 过滤条件：由对方召唤·特殊召唤且可以回到卡组的怪兽
function c84965420.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsAbleToDeck()
end
-- 发动条件：自己场上有仪式怪兽存在，且对方在非连锁处理中进行符合条件的召唤·特殊召唤
function c84965420.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的仪式怪兽
	return Duel.IsExistingMatchingCard(c84965420.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前是否处于非连锁状态，且被召唤·特殊召唤的怪兽中存在满足条件的对方怪兽
		and aux.NegateSummonCondition() and eg:IsExists(c84965420.cfilter,1,nil,tp)
end
-- 效果的目标处理：设置无效召唤和送回卡组的操作信息
function c84965420.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效对应数量怪兽的召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将对应数量的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,eg:GetCount(),0,0)
end
-- 效果的实际处理：使召唤无效并让那些怪兽回到持有者卡组
function c84965420.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤·特殊召唤的怪兽的召唤无效
	Duel.NegateSummon(eg)
	-- 将这些召唤无效的怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
