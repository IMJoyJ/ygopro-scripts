--スフィア・ボム 球体時限爆弾
-- 效果：
-- ①：里侧守备表示的这张卡被对方怪兽攻击的伤害计算前发动。这张卡当作装备卡使用给那只攻击怪兽装备。
-- ②：用这张卡的效果把这张卡装备的下次的对方准备阶段发动。装备怪兽破坏，给与对方那个攻击力数值的伤害。
function c26302522.initial_effect(c)
	-- ①：里侧守备表示的这张卡被对方怪兽攻击的伤害计算前发动。这张卡当作装备卡使用给那只攻击怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26302522,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c26302522.eqcon)
	e1:SetOperation(c26302522.eqop)
	c:RegisterEffect(e1)
end
-- 效果①的发动条件：判断攻击对象是否为这张卡，且这张卡在战斗发生前是否处于里侧守备表示。
function c26302522.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击对象为这张卡，且这张卡在伤害计算前的战斗表示为里侧守备表示，两者同时满足时效果①才能发动。
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 效果①发动后的处理：若攻击怪兽和此卡仍与本次战斗关联，且我方魔陷区有空位、攻击怪兽不是里侧表示，则将此卡装备给攻击怪兽，并追加装备限制和②效果；否则将此卡破坏。
function c26302522.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动攻击的对方怪兽，作为这张卡要装备的目标。
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
	-- 检查我方魔陷区是否还有可用区域，以及攻击怪兽是否为里侧表示；若无空位或攻击怪兽为里侧表示，则无法进行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() then
		-- 因无法装备而将此卡自身破坏。
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 将这张卡当作装备卡，装备给攻击怪兽。
	Duel.Equip(tp,c,tc)
	-- 这张卡当作装备卡使用给那只攻击怪兽装备。
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c26302522.eqlimit)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的下次的对方准备阶段发动。装备怪兽破坏，给与对方那个攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26302522,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c26302522.descon)
	e2:SetTarget(c26302522.destg)
	e2:SetOperation(c26302522.desop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OPPO_TURN+RESET_PHASE+PHASE_STANDBY)
	c:RegisterEffect(e2)
end
-- 装备限制函数：只有作为该效果所有者的那只攻击怪兽才能装备此卡，防止装备给其他怪兽。
function c26302522.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动条件：当前回合是对方的准备阶段（当前回合玩家不是这张卡的控制者tp）。
function c26302522.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是tp；若是，则为对方的准备阶段，满足②效果的发动时点。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果发动时确定处理目标：取得装备怪兽作为对象并建立效果联系，同时设置破坏装备怪兽和给对方造成伤害的操作信息。
function c26302522.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	ec:CreateEffectRelation(e)
	e:SetLabelObject(ec)
	-- 设置操作信息：将装备怪兽作为要破坏的对象，数量为1，分类为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
	-- 设置操作信息：将给予对方玩家伤害，伤害数值为装备怪兽的当前攻击力，分类为伤害效果。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ec:GetAttack())
end
-- ②效果处理：确认此卡和装备怪兽都仍与效果关联且装备怪兽为表侧表示；先破坏装备怪兽，若破坏成功则给对方造成其攻击力数值的伤害，若失败则破坏此卡。
function c26302522.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=e:GetLabelObject()
	if ec:IsRelateToEffect(e) and ec:IsFaceup() then
		local atk=ec:GetAttack()
		-- 实际执行破坏装备怪兽，并判断是否破坏成功（返回值非0）；只有破坏成功才继续给予伤害。
		if Duel.Destroy(ec,REASON_EFFECT)~=0 then
			-- 装备怪兽被破坏成功后，给对方造成其攻击力数值的伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		-- 若装备怪兽没有被破坏（例如因其他效果不能被破坏），则改为破坏这张装备卡自身。
		else Duel.Destroy(c,REASON_EFFECT) end
	end
end
