--武神器－オハバリ
-- 效果：
-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c16157341.initial_effect(c)
	-- 创建效果，设置效果描述为“贯穿附加”，设置效果类型为起动效果，设置效果适用区域为手卡，设置效果条件、费用、对象和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16157341,0))  --"贯穿附加"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16157341.condition)
	e1:SetCost(c16157341.cost)
	e1:SetTarget(c16157341.target)
	e1:SetOperation(c16157341.operation)
	c:RegisterEffect(e1)
end
-- 效果条件函数，检查是否能进入战斗阶段
function c16157341.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果费用函数，检查是否能将自身送去墓地作为费用，并执行送去墓地的操作
function c16157341.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，筛选场上正面表示、名字带有「武神」且未具有贯穿效果的怪兽
function c16157341.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 效果对象选择函数，选择场上一只符合条件的怪兽作为效果对象
function c16157341.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16157341.filter(chkc) end
	-- 检查场上是否存在符合条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c16157341.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上一只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c16157341.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，使选择的怪兽获得贯穿效果
function c16157341.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使选择的怪兽获得贯穿效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
