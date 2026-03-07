--ピューマン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的2只兽战士族怪兽从游戏中除外的场合可以特殊召唤。1回合1次，可以从手卡丢弃1只兽战士族怪兽，从以下效果选择1个发动。
-- ●这张卡的攻击力直到结束阶段时变成2倍。
-- ●这个回合这张卡可以直接攻击对方玩家。
function c38837163.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤规则效果，允许将2只墓地的兽战士族怪兽除外来特殊召唤此卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38837163.spcon)
	e1:SetTarget(c38837163.sptg)
	e1:SetOperation(c38837163.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从手卡丢弃1只兽战士族怪兽，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38837163,0))  --"选择效果发动"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c38837163.cost)
	e2:SetTarget(c38837163.target)
	e2:SetOperation(c38837163.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选墓地中的兽战士族可除外怪兽
function c38837163.spfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件函数，检查是否满足特殊召唤条件
function c38837163.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在至少2只兽战士族怪兽
		and Duel.IsExistingMatchingCard(c38837163.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤目标函数，选择并除外2只墓地的兽战士族怪兽
function c38837163.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地中的所有兽战士族怪兽
	local g=Duel.GetMatchingGroup(c38837163.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤执行函数，将选中的怪兽除外
function c38837163.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤理由除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于筛选手卡中的兽战士族可丢弃怪兽
function c38837163.cfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsDiscardable()
end
-- 效果发动的费用支付函数，丢弃1只手卡的兽战士族怪兽
function c38837163.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡中是否存在至少1只兽战士族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c38837163.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中丢弃1只兽战士族怪兽
	Duel.DiscardHand(tp,c38837163.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果选择函数，让玩家选择发动哪个效果
function c38837163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家选择发动效果1或效果2
	local opt=Duel.SelectOption(tp,aux.Stringid(38837163,1),aux.Stringid(38837163,2))  --"这张卡的攻击力直到结束阶段时变成2倍。/这个回合这张卡可以直接攻击对方玩家。"
	e:SetLabel(opt)
end
-- 效果发动执行函数，根据选择执行对应效果
function c38837163.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if e:GetLabel()==0 then
		-- 使此卡的攻击力直到结束阶段时变成2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	else
		-- 使此卡这个回合可以直接攻击对方玩家
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
