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
-- 装备效果（变成装备卡）的发动条件判断：判断被攻击的怪兽是否为这张卡自身，且这张卡在被攻击前的表示形式为里侧守备表示。
function c4266839.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：当前攻击目标为这张卡，且这张卡在战斗确认时的表示形式为里侧守备表示。
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 装备效果的处理：若攻击怪兽和这张卡仍与本次战斗相关联，且自己魔陷区有空位且攻击怪兽为表侧表示，则将这张卡装备给攻击怪兽，并为装备怪兽添加装备限制，同时为这张卡注册准备阶段回复LP的效果；否则将这张卡破坏。
function c4266839.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽，作为要装备的对象（攻击怪兽）。
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToBattle() or not c:IsRelateToBattle() then return end
	-- 检查自己魔陷区是否有空位，以及攻击怪兽是否为里侧表示；若没有空位或攻击怪兽为里侧表示，则无法进行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() then
		-- 由于无法装备（没有空位或攻击怪兽里侧），将这张卡破坏。
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给攻击怪兽。
	Duel.Equip(tp,c,tc)
	-- 这张卡变成攻击怪兽的装备卡
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
-- 装备限制函数：仅允许效果创建者（即原攻击怪兽）作为这张卡的装备对象。
function c4266839.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 回复LP效果的发动条件：当前回合玩家不是这张卡的控制者，即处于对方的回合。
function c4266839.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：当前回合玩家不等于此卡控制者，也就是对方回合的准备阶段。
	return Duel.GetTurnPlayer()~=tp
end
-- 回复LP效果的发动时处理：设置回复数值为装备怪兽当前攻击力的一半（向上取整），并声明该效果为回复效果。
function c4266839.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	-- 设置操作信息：声明将回复装备怪兽攻击力一半（向上取整）的LP，用于效果发动判定与连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(ec:GetAttack()/2))
end
-- 回复LP效果的处理：若这张卡仍与效果关联且仍装备着怪兽，则回复其控制者该装备怪兽攻击力一半的LP。
function c4266839.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=c:GetEquipTarget()
	if ec then
		local atk=ec:GetAttack()
		-- 实际执行LP回复，回复值为装备怪兽当前攻击力的一半（向上取整）。
		Duel.Recover(tp,math.ceil(atk/2),REASON_EFFECT)
	end
end
