--ダブルアタック
-- 效果：
-- 从手卡丢弃1张怪兽卡去墓地。选择自己场上1只比丢弃怪兽等级低的怪兽。选择的那只怪兽在这个回合可以攻击2次。
function c34187685.initial_effect(c)
	-- 创建一张永续效果，用于处理二重攻击的发动条件、费用、选择目标和发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetLabel(0)
	e1:SetCondition(c34187685.condition)
	e1:SetCost(c34187685.cost)
	e1:SetTarget(c34187685.target)
	e1:SetOperation(c34187685.activate)
	c:RegisterEffect(e1)
end
-- 检查回合玩家能否进入战斗阶段
function c34187685.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 设置费用为丢弃手牌并标记费用已支付
function c34187685.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于选择可以丢弃的手牌：必须是怪兽卡、等级大于1、可以丢弃且能作为墓地代价，并且场上存在符合条件的目标怪兽
function c34187685.filter1(c,tp)
	local lv=c:GetOriginalLevel()
	return lv>1 and c:IsType(TYPE_MONSTER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在满足filter2条件的怪兽
		and Duel.IsExistingTarget(c34187685.filter2,tp,LOCATION_MZONE,0,1,nil,lv)
end
-- 过滤函数，用于选择目标怪兽：必须是表侧表示、等级低于丢弃怪兽等级-1、且未拥有额外攻击效果
function c34187685.filter2(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv-1) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 处理效果的目标选择阶段：先判断是否为对象选择阶段，否则检查是否满足发动条件并选择丢弃手牌和目标怪兽
function c34187685.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34187685.filter2(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在满足filter1条件的怪兽卡
		return Duel.IsExistingMatchingCard(c34187685.filter1,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足filter1条件的手牌并将其丢弃至墓地
	local cg=Duel.SelectMatchingCard(tp,c34187685.filter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将选择的卡丢入墓地，原因包括丢弃和支付代价
	Duel.SendtoGrave(cg,REASON_DISCARD+REASON_COST)
	local lv=cg:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足filter2条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c34187685.filter2,tp,LOCATION_MZONE,0,1,1,nil,lv)
end
-- 处理效果的发动阶段：为选中的怪兽添加额外攻击次数效果
function c34187685.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 使目标怪兽在本回合可以攻击2次
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
