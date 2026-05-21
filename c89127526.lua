--バリア・リゾネーター
-- 效果：
-- 把这张卡从手卡送去墓地，选择自己场上表侧表示存在的1只调整发动。选择的怪兽在这个回合不会被战斗破坏，选择的怪兽的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
function c89127526.initial_effect(c)
	-- 把这张卡从手卡送去墓地，选择自己场上表侧表示存在的1只调整发动。选择的怪兽在这个回合不会被战斗破坏，选择的怪兽的战斗发生的对自己的战斗伤害变成0。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89127526,0))  --"战斗破坏耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c89127526.cost)
	e1:SetTarget(c89127526.target)
	e1:SetOperation(c89127526.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理函数，检查并执行将自身从手卡送去墓地的操作
function c89127526.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：表侧表示的调整怪兽
function c89127526.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 效果的目标选择与合法性检查函数
function c89127526.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c89127526.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的表侧表示调整怪兽
	if chk==0 then return Duel.IsExistingTarget(c89127526.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的调整怪兽作为效果的对象
	Duel.SelectTarget(tp,c89127526.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，为目标怪兽适用不会被战斗破坏以及战斗伤害变为0的效果
function c89127526.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 选择的怪兽的战斗发生的对自己的战斗伤害变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 选择的怪兽在这个回合不会被战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
