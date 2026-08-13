--ヴォルカニック・エッジ
-- 效果：
-- 可以给与对方基本分500分伤害。这个效果1回合只能使用1次。这个效果发动的场合，这个回合这张卡不能攻击。
function c17415895.initial_effect(c)
	-- 可以给与对方基本分500分伤害。这个效果1回合只能使用1次。这个效果发动的场合，这个回合这张卡不能攻击。
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
-- 发动时确认这张卡本回合未进行过攻击宣言，作为代价给自己附加这个回合不能攻击的誓约效果（不会被无效，结束阶段或离场时解除）。
function c17415895.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的场合，这个回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 发动时指定对方玩家作为伤害对象，伤害数值为500，并登记伤害效果的操作信息，以便后续处理。
function c17415895.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），即指定伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，即要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 向系统登记操作信息：本连锁属于伤害效果，目标为对方玩家，数值为500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时，从连锁信息中读取之前指定的对方玩家和伤害值，并实际执行伤害。
function c17415895.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时保存的对象玩家和参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式给予玩家p（对方）d（500）点基本分伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
