--ステルスバード
-- 效果：
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转召唤成功的场合发动。给与对方1000伤害。
function c3510565.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3510565,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c3510565.target)
	e1:SetOperation(c3510565.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡反转召唤成功的场合发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3510565,1))  --"给予对方1000的伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c3510565.damtg)
	e2:SetOperation(c3510565.damop)
	c:RegisterEffect(e2)
end
-- 作为①效果的发动条件检查：这张卡当前可以变为里侧守备表示，且本回合尚未使用过①效果（以3510565号Flag记录）；满足条件时才允许发动，并注册一个当回合结束或离场等情况下重置的Flag标记。
function c3510565.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(3510565)==0 end
	c:RegisterFlagEffect(3510565,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 向系统登记本次连锁将进行“变更表示形式”的操作：目标为这张卡，数量为1，从而使其他卡片能够正确响应这次表示形式变更。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①效果处理时，若这张卡仍与效果关联且处于表侧表示，则将其变成里侧守备表示。
function c3510565.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式改变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动时点处理：由于是必发诱发效果，满足反转召唤成功条件后必定发动（chk==0直接返回true）；同时把伤害对象设为对方玩家、伤害值设为1000，并登记对应的伤害操作信息。
function c3510565.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），即承受伤害的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000，即要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 向系统登记本次连锁将进行“造成伤害”的操作：伤害对象为对方玩家，伤害值为1000；由于伤害对象和数值已通过SetTargetPlayer/SetTargetParam确定，此处targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ②效果处理时，从当前连锁信息中取出此前登记的对象玩家和伤害值，并对该玩家造成效果伤害。
function c3510565.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象玩家和参数值，分别存入变量p（伤害对象）和d（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点伤害，伤害原因为效果（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
