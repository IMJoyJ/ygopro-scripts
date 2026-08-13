--ロケット戦士
-- 效果：
-- ①：自己战斗阶段中，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：这张卡向怪兽攻击的伤害计算后发动。攻击对象怪兽的攻击力直到回合结束时下降500。
function c30860696.initial_effect(c)
	-- ①：自己战斗阶段中，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c30860696.ivcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：自己战斗阶段中，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetCondition(c30860696.ivcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡向怪兽攻击的伤害计算后发动。攻击对象怪兽的攻击力直到回合结束时下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30860696,0))  --"攻击下降"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c30860696.racon)
	e3:SetOperation(c30860696.raop)
	c:RegisterEffect(e3)
end
-- 条件函数：判断当前回合玩家是否为此卡的控制者，用于限定①效果只在自己回合的战斗阶段中适用。
function c30860696.ivcon(e)
	-- 返回当前回合玩家是否等于效果控制者，若为真则满足‘自己战斗阶段中’的条件。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 触发条件：本卡作为攻击者进行了攻击，且攻击对象存在，满足‘这张卡向怪兽攻击的伤害计算后发动’的条件。
function c30860696.racon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回本卡是否为攻击者且攻击对象不为空，即满足‘这张卡向怪兽攻击’的发动条件。
	return e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- 效果处理：获取攻击对象怪兽，若其仍与战斗相关且为表侧表示，则赋予其攻击力下降500的效果直到回合结束。
function c30860696.raop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对象怪兽，用于后续攻击力下降处理。
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() or d:IsFacedown() then return end
	-- 攻击对象怪兽的攻击力直到回合结束时下降500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	d:RegisterEffect(e1)
end
