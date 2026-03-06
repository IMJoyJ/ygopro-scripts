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
-- 效果作用
function c26302522.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击目标是否为该卡且该卡处于里侧守备表示
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 效果作用
function c26302522.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
	-- 判断场上魔陷区是否还有空位或攻击怪兽是否里侧表示
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() then
		-- 将该卡破坏
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 将该卡装备给攻击怪兽
	Duel.Equip(tp,c,tc)
	-- ②：用这张卡的效果把这张卡装备的下次的对方准备阶段发动。装备怪兽破坏，给与对方那个攻击力数值的伤害。
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
-- 装备对象限制效果，确保只有装备怪兽能装备此卡
function c26302522.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果作用
function c26302522.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 效果作用
function c26302522.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	ec:CreateEffectRelation(e)
	e:SetLabelObject(ec)
	-- 设置操作信息：将装备怪兽破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
	-- 设置操作信息：给与对方装备怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ec:GetAttack())
end
-- 效果作用
function c26302522.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=e:GetLabelObject()
	if ec:IsRelateToEffect(e) and ec:IsFaceup() then
		local atk=ec:GetAttack()
		-- 判断装备怪兽是否被成功破坏
		if Duel.Destroy(ec,REASON_EFFECT)~=0 then
			-- 给与对方装备怪兽攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		-- 若装备怪兽未被破坏，则将该卡破坏
		else Duel.Destroy(c,REASON_EFFECT) end
	end
end
