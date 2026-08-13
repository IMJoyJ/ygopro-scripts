--ダイノルフィア・ブルート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把基本分支付一半才能发动。选自己场上1只「恐啡肽狂龙」怪兽和对方场上1张卡破坏。
-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
function c99414629.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把基本分支付一半才能发动。选自己场上1只「恐啡肽狂龙」怪兽和对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,99414629+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c99414629.cost)
	e1:SetTarget(c99414629.target)
	e1:SetOperation(c99414629.operation)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c99414629.cdcon)
	-- 设置②效果发动代价为把墓地的这张卡除外（aux.bfgcost自动处理除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c99414629.cdop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：发动时确认可以支付（chk时返回true），然后支付自己当前基本分的一半（向下取整）作为代价。
function c99414629.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让当前玩家支付其当前LP的一半数值（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义过滤器：选择自己场上表侧表示的属于「恐啡肽狂龙」系列（0x173）的怪兽。
function c99414629.filter(c)
	return c:IsSetCard(0x173) and c:IsFaceup()
end
-- 定义①效果的发动目标条件：自己场上存在至少1只表侧表示的「恐啡肽狂龙」怪兽，且对方场上存在至少1张卡。
function c99414629.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤器（表侧表示「恐啡肽狂龙」怪兽）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c99414629.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张任意卡（aux.TRUE始终为真）作为对象。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己场上所有表侧表示的「恐啡肽狂龙」怪兽，作为可能选择破坏的候选集合。
	local g1=Duel.GetMatchingGroup(c99414629.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有卡（任意卡），作为可能选择破坏的候选集合。
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	g1:Merge(g2)
	-- 设置操作信息：本效果属于破坏效果，候选破坏对象为g1（自己场上恐啡肽狂龙+对方场上所有卡），预计破坏数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 定义①效果处理函数：若自己场上没有恐啡肽狂龙怪兽或对方场上没有卡，则效果不处理（防止空发）。
function c99414629.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上表侧表示的恐啡肽狂龙怪兽数量小于等于0，则结束处理。
	if Duel.GetMatchingGroupCount(c99414629.filter,tp,LOCATION_MZONE,0,nil)<=0
		-- 或者对方场上卡数量小于等于0，也结束处理。
		or Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)<=0 then return end
	-- 向当前玩家显示选择提示「请选择要破坏的卡」，用于选择自己怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从自己场上选择1只表侧表示的「恐啡肽狂龙」怪兽。
	local g1=Duel.SelectMatchingCard(tp,c99414629.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次向当前玩家显示选择提示「请选择要破坏的卡」，用于选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从对方场上选择1张任意卡。
	local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将选中的两组卡合并后显示选中动画，并记录这些卡被选为对象。
	Duel.HintSelection(g1)
	-- 以效果原因破坏合并后所选中的卡（自己1只恐啡肽狂龙和对方1张卡）。
	Duel.Destroy(g1,REASON_EFFECT)
end
-- 定义②效果的发动条件：自己基本分在2000以下，且对方发动了魔法·陷阱·怪兽的效果。
function c99414629.cdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件判定结果：自己LP≤2000且连锁中的效果发动者是对方（rp==1-tp）。
	return Duel.GetLP(tp)<=2000 and rp==1-tp
end
-- 定义②效果发动后的处理：生成两个持续到结束阶段的永续效果来防止对方效果对自己造成的效果伤害。
function c99414629.cdop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c99414629.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果e1给当前玩家：EFFECT_CHANGE_DAMAGE用于在伤害计算时把对方效果造成的伤害改为0（配合damval1）。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果e2给当前玩家：EFFECT_NO_EFFECT_DAMAGE直接使对方效果对自己造成的效果伤害无效化。
	Duel.RegisterEffect(e2,tp)
end
-- damval1是EFFECT_CHANGE_DAMAGE的数值函数：若伤害原因为效果且伤害发动者是对手（与效果所有者不同），则返回0，否则返回原伤害值。
function c99414629.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
