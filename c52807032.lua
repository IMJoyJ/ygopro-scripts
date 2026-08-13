--ダイノルフィア・ソニック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「恐啡肽狂龙」怪兽存在，对方把魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，选自己场上1只「恐啡肽狂龙」怪兽破坏。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c52807032.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「恐啡肽狂龙」怪兽存在，对方把魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，选自己场上1只「恐啡肽狂龙」怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,52807032+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c52807032.condition)
	e1:SetCost(c52807032.cost)
	e1:SetTarget(c52807032.target)
	e1:SetOperation(c52807032.operation)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c52807032.damcon)
	-- 设置②效果的发动代价为把墓地的这张卡除外（aux.bfgcost为通用除外代价函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c52807032.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为表侧表示且属于「恐啡肽狂龙」系列（setname 0x173），用于筛选自己场上的「恐啡肽狂龙」怪兽。
function c52807032.cfilter(c)
	return c:IsSetCard(0x173) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有表侧表示「恐啡肽狂龙」怪兽存在，且对方发动的是魔法·陷阱卡（EFFECT_TYPE_ACTIVATE），该连锁可被无效，并且发动者是对方。
function c52807032.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示「恐啡肽狂龙」怪兽，满足‘自己场上有「恐啡肽狂龙」怪兽存在’。
	return Duel.IsExistingMatchingCard(c52807032.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 进一步验证对方发动的是魔法·陷阱卡的发动且该连锁能被无效，并确认发动者为对方玩家，对应‘对方把魔法·陷阱卡发动时’及可无效条件。
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- ①效果的代价函数：确认可以支付代价（chk==0直接返回true），然后实际支付基本分一半作为发动代价。
function c52807032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付自己当前基本分的一半（向下取整）作为发动代价，对应‘把基本分支付一半才能发动’。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ①效果的目标处理：发动时确认自己场上有「恐啡肽狂龙」怪兽，并设置操作信息，声明将无效并破坏对方发动的魔法·陷阱卡；若该卡可破坏且仍与连锁相关，则同时设置破坏信息。
function c52807032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认自己场上存在表侧表示「恐啡肽狂龙」怪兽，否则不能发动，对应发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c52807032.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息：本效果包含‘无效发动’，目标为对方发动的卡（eg），数量1，用于时点检测和响应。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息：本效果包含‘破坏’，目标为对方发动的卡（eg），数量1，用于时点检测和响应。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的实际处理：先无效并破坏对方发动的魔法·陷阱卡；若成功，则中断效果处理，让玩家选择自己场上1只「恐啡肽狂龙」怪兽并破坏。
function c52807032.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方发动的连锁（ev），并确认要破坏的那张卡仍与效果关联（没有离场或失效），成功后继续后续破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏对方发动的那张魔法·陷阱卡（eg），对应‘那个发动无效并破坏’中的破坏。
		Duel.Destroy(eg,REASON_EFFECT)
		-- 中断当前效果处理，使后面的‘选自己怪兽破坏’与刚才的无效破坏在不同时点处理，避免同时处理导致错乱。
		Duel.BreakEffect()
		-- 向玩家显示选择提示：‘请选择要破坏的卡’，用于下一步选择自己场上要破坏的「恐啡肽狂龙」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从自己场上选择1张表侧表示「恐啡肽狂龙」怪兽（必须选1张），对应‘选自己场上1只「恐啡肽狂龙」怪兽破坏’。
		local g=Duel.SelectMatchingCard(tp,c52807032.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 显示所选择的卡的选中动画，并将该卡记录为被选择的对象。
			Duel.HintSelection(g)
			-- 以效果破坏玩家选择的自己怪兽，对应‘选自己场上1只「恐啡肽狂龙」怪兽破坏’的破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：自己基本分在2000以下，且本次战斗自己将要受到战斗伤害，对应②效果的前置条件。
function c52807032.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己当前基本分≤2000，并且本次战斗伤害计算时自己将受到的战斗伤害>0，满足‘自己基本分是2000以下，自己要受到战斗伤害’。
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- ②效果的实际处理：创建一个避免战斗伤害的效果，使本次战斗对自己的战斗伤害变成0，持续到伤害步骤结束。
function c52807032.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将创建的‘避免战斗伤害’效果注册给tp玩家，使其在本次伤害步骤中生效。
	Duel.RegisterEffect(e1,tp)
end
