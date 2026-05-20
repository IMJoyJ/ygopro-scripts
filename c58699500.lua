--彼岸の黒天使 ケルビーニ
-- 效果：
-- 3星怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡所连接区的怪兽不会被效果破坏。
-- ②：场上的这张卡被战斗或者对方的效果破坏的场合，可以作为代替把自己场上1张卡送去墓地。
-- ③：从卡组把1只3星怪兽送去墓地，以场上1只「彼岸」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的各自数值。
function c58699500.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：3星怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLevel,3),2,2)
	-- ①：这张卡所连接区的怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c58699500.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗或者对方的效果破坏的场合，可以作为代替把自己场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c58699500.desreptg)
	c:RegisterEffect(e2)
	-- ③：从卡组把1只3星怪兽送去墓地，以场上1只「彼岸」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的各自数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58699500,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(0)
	e3:SetCountLimit(1,58699500)
	e3:SetCost(c58699500.atkcost)
	e3:SetTarget(c58699500.atktg)
	e3:SetOperation(c58699500.atkop)
	c:RegisterEffect(e3)
end
-- 确定目标怪兽是否处于这张卡的连接区
function c58699500.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 过滤场上可以作为代替送去墓地的卡（非预定破坏且不免疫该效果）
function c58699500.repfilter(c,e)
	return not c:IsStatus(STATUS_DESTROY_CONFIRMED) and not c:IsImmuneToEffect(e)
end
-- 代替破坏效果的准备：检查自身是否因战斗或对方效果破坏，并确认场上是否存在可代替送墓的卡
function c58699500.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or rp==1-tp)
		-- 检查自己场上是否存在至少1张可以代替送去墓地的卡（不包括自身）
		and Duel.IsExistingMatchingCard(c58699500.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 设置选择要送去墓地的卡的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择自己场上1张卡作为代替破坏的卡
		local g=Duel.SelectMatchingCard(tp,c58699500.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
		-- 将选中的卡作为代替送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 起动效果的Cost处理：标记Cost检查状态
function c58699500.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤卡组中可以作为Cost送去墓地的3星怪兽
function c58699500.cfilter(c)
	return c:IsLevel(3) and (c:GetBaseAttack()>0 or c:GetBaseDefense()>0) and c:IsAbleToGraveAsCost()
end
-- 过滤场上表侧表示的「彼岸」怪兽
function c58699500.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb1)
end
-- 起动效果的Target处理：从卡组将1只3星怪兽送去墓地作为发动Cost，并选择场上1只「彼岸」怪兽作为效果对象
function c58699500.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58699500.filter(chkc) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在满足Cost条件的3星怪兽
		return Duel.IsExistingMatchingCard(c58699500.cfilter,tp,LOCATION_DECK,0,1,nil)
			-- 检查场上是否存在可以作为效果对象的「彼岸」怪兽
			and Duel.IsExistingTarget(c58699500.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	e:SetLabel(0)
	-- 设置选择要送去墓地的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的3星怪兽
	local g=Duel.SelectMatchingCard(tp,c58699500.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为发动Cost
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	-- 设置选择表侧表示怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示的「彼岸」怪兽作为效果对象
	Duel.SelectTarget(tp,c58699500.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 起动效果的Operation处理：使作为对象的「彼岸」怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的各自数值
function c58699500.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（即选中的「彼岸」怪兽）
	local tc=Duel.GetFirstTarget()
	local sc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and sc then
		-- 那只怪兽的攻击力直到回合结束时上升送去墓地的怪兽的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(sc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(sc:GetDefense())
		tc:RegisterEffect(e2)
	end
end
