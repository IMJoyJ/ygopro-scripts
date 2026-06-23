--妖怪のいたずら
-- 效果：
-- ①：场上的全部怪兽的等级直到回合结束时下降2星。
-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时下降1星。这个效果在这张卡送去墓地的回合不能发动。
function c29795530.initial_effect(c)
	-- ①：场上的全部怪兽的等级直到回合结束时下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c29795530.target)
	e1:SetOperation(c29795530.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时下降1星。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29795530,0))  --"等级下降"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动这个效果
	e2:SetCondition(aux.exccon)
	-- 设置效果的费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c29795530.lvtg)
	e2:SetOperation(c29795530.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查怪兽是否表侧表示且等级大于等于2
function c29795530.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 效果处理函数：检查场上是否存在至少1只满足条件的怪兽
function c29795530.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：将场上所有满足条件的怪兽等级下降2星
function c29795530.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每只怪兽创建一个等级下降2的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果处理函数：选择场上1只满足条件的怪兽作为对象
function c29795530.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29795530.filter(chkc) end
	-- 检查场上是否存在至少1只满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数：将选中的怪兽等级下降1星
function c29795530.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为选中的怪兽创建一个等级下降1的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
