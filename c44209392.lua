--城壁
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。选择的怪兽的守备力直到结束阶段时上升500。
function c44209392.initial_effect(c)
	-- 创建城壁效果，设置为魔陷发动、取对象、伤害步骤可发动，自由时点，提示伤害步骤时点，限制发动时机为伤害计算前，设置目标函数和发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c44209392.target)
	e1:SetOperation(c44209392.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择表侧表示且守备力大于等于0的怪兽
function c44209392.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 目标选择函数：选择场上表侧表示存在的1只怪兽作为效果对象
function c44209392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44209392.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c44209392.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c44209392.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 发动效果函数：将选择的怪兽守备力上升500
function c44209392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给目标怪兽添加守备力上升500的效果，直到结束阶段时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
