--先史遺産ヴィマナ
-- 效果：
-- 5星怪兽×2
-- ①：自己·对方回合1次，以场上1只表侧表示怪兽和自己墓地1只「先史遗产」怪兽或超量怪兽为对象才能发动。那只场上的怪兽的攻击力直到回合结束时上升作为对象的墓地的怪兽的攻击力一半数值。那之后，把作为对象的墓地的怪兽作为这张卡的超量素材。
-- ②：1回合1次，对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效。
function c2609443.initial_effect(c)
	-- 为当前卡片添加超量召唤流程，等级5需要2个素材。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，以场上1只表侧表示怪兽和自己墓地1只「先史遗产」怪兽或超量怪兽为对象才能发动。那只场上的怪兽的攻击力直到回合结束时上升作为对象的墓地的怪兽的攻击力一半数值。那之后，把作为对象的墓地的怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2609443,0))  --"上升攻击力并补充素材"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	-- 设置效果发动条件，使用aux.dscon函数判断是否在伤害步骤以外或尚未进行伤害计算。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c2609443.atktg)
	e1:SetOperation(c2609443.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2609443,1))  --"对方怪兽发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c2609443.discon)
	e2:SetCost(c2609443.discost)
	e2:SetTarget(c2609443.distg)
	e2:SetOperation(c2609443.disop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数，用于筛选墓地中符合条件的“先史遗产”怪兽或超量怪兽（表侧表示、攻击力大于0）。
function c2609443.atkfilter(c)
	return (c:IsSetCard(0x70) or c:IsType(TYPE_XYZ)) and c:IsType(TYPE_MONSTER) and c:GetAttack()>0
end
-- 设置效果的目标选择条件和操作。
function c2609443.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 判断场上是否存在表侧表示的卡片。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 判断墓地中是否存在符合atkfilter条件的卡片。
		and Duel.IsExistingTarget(c2609443.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从主要怪兽区或额外怪兽区选择一张表侧表示的卡片作为目标。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 向玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从墓地中选择一张符合atkfilter条件的卡片作为目标。
	local g2=Duel.SelectTarget(tp,c2609443.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表明将选定的墓地卡片移除。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- 实现攻击力上升和补充素材的效果。首先获取标签对象（场上怪兽），然后计算一半的墓地怪兽攻击力并将其加到场上怪兽身上。如果满足条件，则将墓地怪兽作为超量素材覆盖到这张卡上。
function c2609443.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中的目标卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sc=g:GetFirst()
	if sc==tc then sc=g:GetNext() end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	if not ac:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 设置单张效果，更新攻击力为一半的墓地怪兽攻击力，并在回合结束时重置。注册该效果到目标卡片上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ac:RegisterEffect(e1)
		if not ac:IsHasEffect(EFFECT_REVERSE_UPDATE) and e:GetHandler():IsRelateToEffect(e) and tc:IsCanOverlay() then
			-- 中断当前效果，防止后续效果同时处理。
			Duel.BreakEffect()
			-- 将选定的墓地怪兽作为超量素材覆盖到这张卡上。
			Duel.Overlay(e:GetHandler(),tc)
		end
	end
end
-- 设置使对方怪兽效果无效的效果的条件。判断是否为对方回合、自身未被战斗破坏、连锁可以被无效以及目标是激活中的怪兽。
function c2609443.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回一个布尔值，表示是否满足使对方怪兽效果无效的条件。
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 设置使对方怪兽效果无效的效果的费用。检查是否有足够的超量素材用于支付费用。
function c2609443.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	-- 向玩家发送提示信息，要求选择要取除的超量素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 设置使对方怪兽效果无效的效果的目标。如果检查成功，则返回true。
function c2609443.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明将使连锁中的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 实现使对方怪兽效果无效的操作。使用Duel.NegateActivation函数使连锁中的效果无效。
function c2609443.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁中的效果无效。
	Duel.NegateActivation(ev)
end
