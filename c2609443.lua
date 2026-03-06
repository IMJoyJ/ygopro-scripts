--先史遺産ヴィマナ
-- 效果：
-- 5星怪兽×2
-- ①：自己·对方回合1次，以场上1只表侧表示怪兽和自己墓地1只「先史遗产」怪兽或超量怪兽为对象才能发动。那只场上的怪兽的攻击力直到回合结束时上升作为对象的墓地的怪兽的攻击力一半数值。那之后，把作为对象的墓地的怪兽作为这张卡的超量素材。
-- ②：1回合1次，对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效。
function c2609443.initial_effect(c)
	-- 为卡片添加等级为5、需要2只怪兽作为超量素材的超量召唤手续
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
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为：当前阶段非伤害阶段或尚未进行伤害计算
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
-- 定义用于筛选墓地怪兽的过滤器，要求为「先史遗产」卡组或超量怪兽且攻击力大于0
function c2609443.atkfilter(c)
	return (c:IsSetCard(0x70) or c:IsType(TYPE_XYZ)) and c:IsType(TYPE_MONSTER) and c:GetAttack()>0
end
-- 设置效果发动时的条件判断，检查是否满足选择场上的1只表侧表示怪兽和墓地的1只符合条件怪兽
function c2609443.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查场上是否存在1只表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查墓地是否存在1只符合条件的怪兽
		and Duel.IsExistingTarget(c2609443.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择场上1只表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择墓地中的1只符合条件的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地中的1只符合条件的怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c2609443.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，标记将有1张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- 处理效果的执行逻辑，包括攻击力提升和将怪兽叠放至自身
function c2609443.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选择的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sc=g:GetFirst()
	if sc==tc then sc=g:GetNext() end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	if not ac:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 创建一个使目标怪兽攻击力提升的效果，提升值为对方怪兽攻击力的一半（向上取整）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ac:RegisterEffect(e1)
		if not ac:IsHasEffect(EFFECT_REVERSE_UPDATE) and e:GetHandler():IsRelateToEffect(e) and tc:IsCanOverlay() then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将目标怪兽叠放至自身作为超量素材
			Duel.Overlay(e:GetHandler(),tc)
		end
	end
end
-- 定义无效对方怪兽效果发动的条件函数
function c2609443.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：对方玩家发动效果、自身未在战斗中被破坏、该连锁可被无效、且发动的是怪兽卡
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
-- 定义消耗2个超量素材的费用函数
function c2609443.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	-- 提示玩家选择要取除的2个超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 定义无效对方怪兽效果发动的目标设定函数
function c2609443.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，标记将使一个连锁发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 定义无效对方怪兽效果发动的处理函数
function c2609443.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁发动无效
	Duel.NegateActivation(ev)
end
