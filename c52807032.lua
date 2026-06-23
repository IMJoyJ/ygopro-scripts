--ダイノルフィア・ソニック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「恐啡肽狂龙」怪兽存在，对方把魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，选自己场上1只「恐啡肽狂龙」怪兽破坏。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c52807032.initial_effect(c)
	-- ①：自己场上有「恐啡肽狂龙」怪兽存在，对方把魔法·陷阱卡发动时，把基本分支付一半才能发动。那个发动无效并破坏。那之后，选自己场上1只「恐啡肽狂龙」怪兽破坏。
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
	-- 效果cost为将此卡从场上除外
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c52807032.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「恐啡肽狂龙」怪兽且处于表侧表示
function c52807032.cfilter(c)
	return c:IsSetCard(0x173) and c:IsFaceup()
end
-- 效果发动条件：对方发动魔法或陷阱卡，且自己场上有「恐啡肽狂龙」怪兽存在，且该连锁可以被无效
function c52807032.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「恐啡肽狂龙」怪兽
	return Duel.IsExistingMatchingCard(c52807032.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方发动的是魔法或陷阱卡，且该连锁可以被无效，并且是对方发动的
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 支付一半基本分作为效果cost
function c52807032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置效果处理时的操作信息：使对方发动无效，并可能破坏对方的魔法或陷阱卡
function c52807032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只「恐啡肽狂龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52807032.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息为使对方发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏对方发动的魔法或陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：使对方发动无效并破坏其魔法或陷阱卡，然后选择破坏自己场上的1只「恐啡肽狂龙」怪兽
function c52807032.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使对方发动无效，并且对方发动的卡仍然有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动的魔法或陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
		-- 中断当前效果处理，防止后续效果同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己场上1只「恐啡肽狂龙」怪兽作为破坏对象
		local g=Duel.SelectMatchingCard(tp,c52807032.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 显示所选怪兽被破坏的动画效果
			Duel.HintSelection(g)
			-- 破坏选定的「恐啡肽狂龙」怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 战斗伤害计算前的条件判断：自己的基本分不超过2000点，且本次战斗将受到伤害
function c52807032.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的基本分是否小于等于2000，并且在本次战斗中将受到伤害
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- 效果处理函数：使自己在本次战斗中不会受到战斗伤害
function c52807032.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个永续效果，使自己在本次战斗中不会受到战斗伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将该效果注册给发动者
	Duel.RegisterEffect(e1,tp)
end
