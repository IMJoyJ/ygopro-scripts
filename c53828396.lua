--瞬着ボマー
-- 效果：
-- 里侧守备表示的这张卡被对方怪兽攻击的场合，不进行伤害计算让这张卡变成攻击怪兽的装备卡。下次的对方回合的准备阶段时，那只装备怪兽破坏。
function c53828396.initial_effect(c)
	-- 里侧守备表示的这张卡被对方怪兽攻击的场合，不进行伤害计算让这张卡变成攻击怪兽的装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53828396,0))  --"变成装备卡"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c53828396.eqcon)
	e1:SetOperation(c53828396.eqop)
	c:RegisterEffect(e1)
end
-- 判断攻击目标是否为该卡且该卡处于里侧守备表示
function c53828396.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击目标为该卡且该卡处于里侧守备表示
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 处理装备效果：获取攻击怪兽，检查是否满足装备条件，若不满足则破坏该卡，否则进行装备操作
function c53828396.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
	-- 判断场上魔陷区是否还有空位或攻击怪兽是否里侧表示
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() then
		-- 若场上魔陷区无空位或攻击怪兽为里侧表示，则将该卡破坏
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 将该卡装备给攻击怪兽
	Duel.Equip(tp,c,tc)
	-- 为装备怪兽设置装备限制效果，防止被其他卡装备
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c53828396.eqlimit)
	c:RegisterEffect(e1)
	-- 下次的对方回合的准备阶段时，那只装备怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53828396,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53828396.descon)
	e2:SetTarget(c53828396.destg)
	e2:SetOperation(c53828396.desop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	c:RegisterEffect(e2)
end
-- 装备限制效果的判断函数，确保只能装备给拥有者
function c53828396.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断当前回合玩家是否为非发动者
function c53828396.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是发动者
	return Duel.GetTurnPlayer()~=tp
end
-- 设置破坏效果的目标信息，确定要破坏的装备怪兽
function c53828396.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	ec:CreateEffectRelation(e)
	e:SetLabelObject(ec)
	-- 设置连锁操作信息，指定要破坏的装备怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 执行破坏效果：若装备怪兽存在且表侧表示，则破坏该怪兽，否则破坏装备卡
function c53828396.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=e:GetLabelObject()
	if ec:IsRelateToEffect(e) and ec:IsFaceup() then
		-- 若破坏装备怪兽成功，则不执行后续破坏操作
		if Duel.Destroy(ec,REASON_EFFECT)~=0 then
		-- 若破坏装备怪兽失败，则将装备卡破坏
		else Duel.Destroy(c,REASON_EFFECT) end
	end
end
