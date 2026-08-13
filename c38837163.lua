--ピューマン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的2只兽战士族怪兽从游戏中除外的场合可以特殊召唤。1回合1次，可以从手卡丢弃1只兽战士族怪兽，从以下效果选择1个发动。
-- ●这张卡的攻击力直到结束阶段时变成2倍。
-- ●这个回合这张卡可以直接攻击对方玩家。
function c38837163.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己墓地存在的2只兽战士族怪兽从游戏中除外的场合可以特殊召唤。
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
-- 筛选可作为特殊召唤代价的卡：从墓地选择兽战士族怪兽且可以作为代价除外。
function c38837163.spfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则效果的发动条件：自己主要怪兽区有空位，且自己墓地存在至少2只可作为代价除外的兽战士族怪兽。
function c38837163.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有可用的空格，确保有特殊召唤的位置。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否至少有2只满足spfilter条件的兽战士族怪兽（即可以作为代价除外的兽战士族怪兽）。
		and Duel.IsExistingMatchingCard(c38837163.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 选择要除外的2只兽战士族怪兽作为特殊召唤代价；若成功选择则保存该选择并返回true，否则取消则返回false。
function c38837163.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter条件的兽战士族怪兽，组成候选集合。
	local g=Duel.GetMatchingGroup(c38837163.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示选择提示，要求从候选集合中选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续处理：取出之前保存的所选卡组，将其除外，从而完成特殊召唤。
function c38837163.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的2只兽战士族怪兽以表侧表示除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 筛选可作为发动代价的手卡：兽战士族怪兽且可以从手卡丢弃。
function c38837163.cfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsDiscardable()
end
-- 代价支付函数：检查并实际执行从手卡丢弃1只兽战士族怪兽作为发动代价。
function c38837163.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中是否存在至少1只满足条件的兽战士族怪兽，以决定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c38837163.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃：玩家从手卡选择并丢弃1只满足条件的兽战士族怪兽，丢弃原因为代价+丢弃。
	Duel.DiscardHand(tp,c38837163.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动时选择要使用的效果：通过选项决定是攻击力翻倍还是获得直接攻击能力，并将选择结果记录到效果e的标签中。
function c38837163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 弹出选项菜单，让玩家选择“攻击力翻倍”或“直接攻击”中的一项。
	local opt=Duel.SelectOption(tp,aux.Stringid(38837163,1),aux.Stringid(38837163,2))  --"这张卡的攻击力直到结束阶段时变成2倍。/这个回合这张卡可以直接攻击对方玩家。"
	e:SetLabel(opt)
end
-- 效果处理：根据之前选择的选项，为这张卡注册攻击力变为2倍或本回合可以直接攻击的持续效果。
function c38837163.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if e:GetLabel()==0 then
		-- ●这张卡的攻击力直到结束阶段时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	else
		-- ●这个回合这张卡可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
