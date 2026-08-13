--F.A.ライトニングマスター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡的攻击力上升这张卡的等级×300。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ④：1回合1次，对方把魔法·陷阱卡的效果发动时才能发动。这张卡的等级下降2星，那个发动无效并破坏。
function c33158448.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续，素材为任意调整1只＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡的攻击力上升这张卡的等级×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c33158448.atkval)
	c:RegisterEffect(e1)
	-- ③：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33158448,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c33158448.lvcon)
	e3:SetOperation(c33158448.lvop)
	c:RegisterEffect(e3)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	-- ④：1回合1次，对方把魔法·陷阱卡的效果发动时才能发动。这张卡的等级下降2星，那个发动无效并破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(33158448,1))
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c33158448.negcon)
	e5:SetTarget(c33158448.negtg)
	e5:SetOperation(c33158448.negop)
	c:RegisterEffect(e5)
end
-- 作为①的攻击力变化值函数，返回这张卡的当前等级乘以300，用于永续提升攻击力。
function c33158448.atkval(e,c)
	return c:GetLevel()*300
end
-- ③效果的发动条件：仅在连锁发动的效果是「方程式运动员」魔法·陷阱卡的效果时满足。
function c33158448.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- ③效果处理时，若这张卡仍与效果相关且表侧表示，则给它赋予一个等级上升1星的持续效果。
function c33158448.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_LEVEL)
		e4:SetValue(1)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e4)
	end
end
-- ④效果的发动条件：对方发动魔法·陷阱卡效果，且这张卡未处于战斗破坏确定状态，且该连锁可被无效。
function c33158448.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查发动效果是否为魔法·陷阱卡效果，且该连锁能够被无效。
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- ④发动时的合法性检查：自身等级不低于3，并设置无效对方发动的魔法·陷阱卡、以及可能破坏该卡的操作信息。
function c33158448.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(3) end
	-- 设置操作信息：声明本次效果处理包含“无效对方魔法·陷阱卡效果”的分类，对象为当前连锁中的那张卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若对方发动的魔法·陷阱卡可被破坏且仍与效果相关，则声明本次处理包含“破坏该卡”的分类。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ④效果处理时，若这张卡表侧且与效果相关、不免疫此效果、等级不低于2，则令其等级下降2星；若无效发动成功且对方卡仍与连锁相关，则将其破坏。
function c33158448.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsLevelBelow(2) then return end
	-- 这张卡的等级下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-2)
	c:RegisterEffect(e1)
	-- 尝试无效连锁中对方效果的发动，并确认对方那张魔法·陷阱卡仍与效果相关，以决定是否继续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏对方发动的魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
