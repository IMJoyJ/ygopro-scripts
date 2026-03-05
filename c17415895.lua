--ヴォルカニック・エッジ
-- 效果：
-- 可以给与对方基本分500分伤害。这个效果1回合只能使用1次。这个效果发动的场合，这个回合这张卡不能攻击。
function c17415895.initial_effect(c)
	-- 创建一个起动效果，用于给予对方500伤害，且此效果1回合只能使用1次，发动时该卡不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17415895,0))  --"给予对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c17415895.cost)
	e1:SetTarget(c17415895.target)
	e1:SetOperation(c17415895.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时检查该卡是否已宣布过攻击，若未宣布则设置该卡在本回合不能攻击
function c17415895.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 设置该卡在本回合不能攻击的效果，且该效果不会被无效，会在结束阶段重置
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 设置效果的目标为对方玩家，伤害值为500
function c17415895.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为500点伤害
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为伤害效果，目标为对方玩家，伤害值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果发动时执行伤害处理，对目标玩家造成500点伤害
function c17415895.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
