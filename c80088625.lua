--バイナル・ブレーダー
-- 效果：
-- 通常怪兽2只
-- ①：得到和这张卡互相连接的怪兽数量的以下效果。
-- ●1只以上：这张卡向对方怪兽攻击的攻击宣言时才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击，这张卡和对方怪兽进行战斗的场合，那只对方怪兽不会被那次战斗破坏。
-- ●2只：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
function c80088625.initial_effect(c)
	-- 设置连接召唤的手续，需要2只通常怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_NORMAL),2,2)
	c:EnableReviveLimit()
	-- ●1只以上：这张卡向对方怪兽攻击的攻击宣言时才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击，这张卡和对方怪兽进行战斗的场合，那只对方怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80088625,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c80088625.atkcon)
	e1:SetOperation(c80088625.atkop)
	c:RegisterEffect(e1)
	-- ●2只：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80088625,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c80088625.rmcon)
	e2:SetTarget(c80088625.rmtg)
	e2:SetOperation(c80088625.rmop)
	c:RegisterEffect(e2)
end
-- 定义攻击宣言时效果的发动条件函数
function c80088625.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在攻击对象（向怪兽攻击）且自身互相连接的怪兽数量大于0
	return Duel.GetAttackTarget()~=nil and e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 定义攻击宣言时效果的操作函数，赋予自身追加攻击和战斗不破坏对方的效果
function c80088625.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这张卡和对方怪兽进行战斗的场合，那只对方怪兽不会被那次战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetTarget(c80088625.indtg)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 过滤不会被战斗破坏的对象，限定为与自身进行战斗的怪兽
function c80088625.indtg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 定义伤害计算后效果的发动条件函数，检查互相连接数量是否为2以及对方怪兽状态
function c80088625.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return c:GetMutualLinkedGroupCount()==2 and bc and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle()
end
-- 定义伤害计算后效果的靶向函数，检查目标是否可除外并设置操作信息
function c80088625.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc:IsAbleToRemove() end
	-- 设置效果处理的操作信息为将该对方怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 定义伤害计算后效果的操作函数，将进行战斗的对方怪兽除外
function c80088625.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将进行战斗的对方怪兽表侧表示除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
