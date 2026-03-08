--精神寄生体
-- 效果：
-- 场上里侧守备表示存在的这张卡被对方怪兽攻击的场合，那次伤害计算前这张卡变成攻击怪兽的装备卡。每次对方的准备阶段，自己基本分回复这张卡的装备怪兽的攻击力一半的数值。
function c4266839.initial_effect(c)
	-- 场上里侧守备表示存在的这张卡被对方怪兽攻击的场合，那次伤害计算前这张卡变成攻击怪兽的装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4266839,0))  --"变成装备卡"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c4266839.eqcon)
	e1:SetOperation(c4266839.eqop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方怪兽攻击此卡且此卡为里侧守备表示
function c4266839.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方怪兽攻击此卡且此卡为里侧守备表示
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 将此卡装备给攻击怪兽并设置装备限制和回复LP效果
function c4266839.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
	-- 判断装备区域是否已满或攻击怪兽为里侧表示
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() then
		-- 若装备失败则破坏此卡
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 将此卡装备给攻击怪兽
	Duel.Equip(tp,c,tc)
	-- 装备对象限制，确保此卡只能装备给拥有者
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c4266839.eqlimit)
	c:RegisterEffect(e1)
	-- 每次对方的准备阶段，自己基本分回复这张卡的装备怪兽的攻击力一半的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4266839,1))  --"回复LP"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c4266839.recon)
	e2:SetTarget(c4266839.retg)
	e2:SetOperation(c4266839.reop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制函数，确保只能装备给拥有者
function c4266839.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断是否为对方回合
function c4266839.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 设置回复LP效果的目标和数值
function c4266839.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	-- 设置回复LP效果的目标和数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(ec:GetAttack()/2))
end
-- 执行回复LP效果
function c4266839.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=c:GetEquipTarget()
	if ec then
		local atk=ec:GetAttack()
		-- 使玩家回复装备怪兽攻击力一半的LP
		Duel.Recover(tp,math.ceil(atk/2),REASON_EFFECT)
	end
end
