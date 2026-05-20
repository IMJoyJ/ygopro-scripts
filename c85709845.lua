--ガムシャラ
-- 效果：
-- 自己场上守备表示存在的怪兽成为攻击对象时才能发动。那只守备表示怪兽的表示形式变更为表侧攻击表示。并且，那次战斗破坏攻击怪兽送去墓地时，再给与对方基本分那只怪兽的原本攻击力数值的伤害。
function c85709845.initial_effect(c)
	-- 自己场上守备表示存在的怪兽成为攻击对象时才能发动。那只守备表示怪兽的表示形式变更为表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c85709845.target)
	e1:SetOperation(c85709845.activate)
	c:RegisterEffect(e1)
end
-- 发动的效果目标检测：验证被攻击的怪兽是否为自己场上的守备表示怪兽，并将其设为效果处理的对象
function c85709845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d:IsDefensePos() and d:IsControler(tp) end
	-- 将被攻击的怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(d)
end
-- 效果处理：将目标怪兽变更为表侧攻击表示，并注册一个在伤害步骤内有效的、在攻击怪兽被战斗破坏送去墓地时给与对方伤害的延迟触发效果
function c85709845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为效果处理对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsDefensePos() then
		-- 将目标怪兽的表示形式变更为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		-- 并且，那次战斗破坏攻击怪兽送去墓地时，再给与对方基本分那只怪兽的原本攻击力数值的伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(85709845,0))  --"伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_DESTROYED)
		e1:SetCondition(c85709845.damcon)
		e1:SetTarget(c85709845.damtg)
		e1:SetOperation(c85709845.damop)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 在全局环境中注册该效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害效果的触发条件：检查被战斗破坏送去墓地的怪兽是否为那只进行攻击的怪兽
function c85709845.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local tc=Duel.GetAttacker()
	return eg:IsContains(tc) and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 伤害效果的目标检测：设置伤害效果的目标玩家为对方，目标参数为攻击怪兽的原本攻击力，并设置操作信息
function c85709845.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取攻击怪兽的原本攻击力
	local atk=Duel.GetAttacker():GetBaseAttack()
	if atk<0 then atk=0 end
	-- 将效果处理的目标玩家设为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果处理的目标参数设为攻击怪兽的原本攻击力
	Duel.SetTargetParam(atk)
	-- 设置当前连锁的操作信息为给与对方原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 伤害效果的处理：获取目标玩家和伤害数值，并给与对方相应的效果伤害
function c85709845.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
