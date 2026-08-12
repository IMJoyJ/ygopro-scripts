--魔鏡導士リフレクト・バウンダー
-- 效果：
-- 场上表侧攻击表示存在的这张卡被对方怪兽攻击的场合，那次伤害计算前给与对方基本分攻击怪兽的攻击力数值的伤害，那次伤害计算后这张卡破坏。
function c2851070.initial_effect(c)
	-- 创建一个诱发必发效果，用于在伤害计算前给与对方基本分伤害
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2851070,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c2851070.damcon)
	e1:SetTarget(c2851070.damtg)
	e1:SetOperation(c2851070.damop)
	c:RegisterEffect(e1)
	-- 创建一个诱发必发效果，用于在伤害计算后将自身破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2851070,1))  --"自坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c2851070.destg)
	e1:SetOperation(c2851070.desop)
	c:RegisterEffect(e1)
end
-- 效果条件：判断攻击怪兽是否为自身且处于表侧攻击表示
function c2851070.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在攻击的怪兽的目标怪兽（即自身）
	local c=Duel.GetAttackTarget()
	return c==e:GetHandler() and c:GetBattlePosition()==POS_FACEUP_ATTACK
end
-- 效果目标：设置伤害对象为对方玩家
function c2851070.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为伤害效果，对象为对方玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理：对对方玩家造成攻击怪兽攻击力数值的伤害
function c2851070.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 记录伤害前的对方LP
	local lp1=Duel.GetLP(p)
	-- 对目标玩家造成攻击怪兽攻击力数值的伤害
	Duel.Damage(p,Duel.GetAttacker():GetAttack(),REASON_EFFECT)
	-- 记录伤害后的对方LP
	local lp2=Duel.GetLP(p)
	if lp2<lp1 then
		e:GetHandler():RegisterFlagEffect(2851070,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 效果目标：判断自身是否拥有标记以触发破坏效果
function c2851070.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(2851070)~=0 end
	-- 设置连锁操作信息为破坏效果，对象为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身破坏
function c2851070.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以效果原因破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
