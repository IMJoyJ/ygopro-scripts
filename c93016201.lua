--王宮の弾圧
-- 效果：
-- 可以支付800基本分，怪兽的特殊召唤以及包含怪兽的特殊召唤的效果无效并破坏。这个效果对方玩家也能使用。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动（自由时点）、卡片发动时无效特殊召唤的效果、在场上表侧表示存在时双方可发动的无效特殊召唤效果、以及在场上表侧表示存在时双方可发动的无效含特召效果的效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 可以支付800基本分，怪兽的特殊召唤...无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"无效特殊召唤"
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	-- 可以支付800基本分，怪兽的特殊召唤...无效并破坏。这个效果对方玩家也能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"无效特殊召唤"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCondition(s.con2)
	e3:SetCost(s.cost2)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.activate2)
	c:RegisterEffect(e3)
	-- 可以支付800基本分，...包含怪兽的特殊召唤的效果无效并破坏。这个效果对方玩家也能使用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"无效特殊召唤"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.condition3)
	e4:SetCost(s.cost3)
	e4:SetTarget(s.target3)
	e4:SetOperation(s.activate3)
	c:RegisterEffect(e4)
end
-- 无效特殊召唤效果的判定条件函数
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于非连锁状态下的特殊召唤时机（即可以无效召唤的时机）
	return aux.NegateSummonCondition()
end
-- 无效特殊召唤效果的消耗（Cost）函数
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800点基本分作为发动代价
	Duel.PayLPCost(tp,800)
end
-- 无效特殊召唤效果的目标（Target）函数
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要无效该特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将要破坏进行特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 无效特殊召唤效果的处理（Operation）函数
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏该特殊召唤的怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 无效包含特殊召唤的效果的判定条件函数
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被连锁的效果是否包含特殊召唤分类，且该连锁的效果可以被无效
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainDisablable(ev)
end
-- 无效包含特殊召唤的效果的消耗（Cost）函数
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800点基本分作为发动代价
	Duel.PayLPCost(tp,800)
end
-- 无效包含特殊召唤的效果的目标（Target）函数
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要无效该效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果发动该效果的卡片可以被破坏且仍存在于关联位置，则将要破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效包含特殊召唤的效果的处理（Operation）函数
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该效果无效，且该卡片仍与效果关联
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
