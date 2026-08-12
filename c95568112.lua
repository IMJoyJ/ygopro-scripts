--レイン・ボーズ
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升双方的额外卡组的数量差×100。
-- 【怪兽效果】
-- ①：这张卡在自己回合内是攻击力，在对方回合内是守备力，上升双方的额外卡组的数量差×200。
-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c95568112.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡的发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升双方的额外卡组的数量差×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95568112,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c95568112.atkcon1)
	e1:SetTarget(c95568112.atktg1)
	e1:SetOperation(c95568112.atkop1)
	c:RegisterEffect(e1)
	-- ①：这张卡在自己回合内是攻击力，在对方回合内是守备力，上升双方的额外卡组的数量差×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c95568112.atkcon2)
	e2:SetValue(c95568112.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetCondition(c95568112.defcon)
	c:RegisterEffect(e3)
	-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c95568112.poscon)
	e4:SetOperation(c95568112.posop)
	c:RegisterEffect(e4)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(95568112,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c95568112.pencon)
	e5:SetTarget(c95568112.pentg)
	e5:SetOperation(c95568112.penop)
	c:RegisterEffect(e5)
end
-- 灵摆效果①的发动条件判定函数
function c95568112.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定双方额外卡组的数量差是否大于0
	return math.abs(Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA))>0
end
-- 灵摆效果①的对象选择与发动准备函数
function c95568112.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动时，检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果①的效果处理（上升攻击力）函数
function c95568112.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取已选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 计算双方额外卡组的数量差
	local atk=math.abs(Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA))
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and atk>0 then
		-- 那只怪兽的攻击力直到回合结束时上升双方的额外卡组的数量差×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果①（自己回合上升攻击力）的适用条件判定函数
function c95568112.atkcon2(e)
	-- 判定当前是否为自己的回合
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 怪兽效果①（攻击力/守备力上升数值）的计算函数
function c95568112.atkval(e,c)
	local tp=c:GetControler()
	-- 计算并返回双方额外卡组的数量差乘以200的数值
	return math.abs(Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA))*200
end
-- 怪兽效果①（对方回合上升守备力）的适用条件判定函数
function c95568112.defcon(e)
	-- 判定当前是否为对方的回合
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 怪兽效果②（战斗阶段结束变守备）的发动条件判定函数（判定这张卡是否进行过攻击）
function c95568112.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 怪兽效果②的效果处理（变成守备表示）函数
function c95568112.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 怪兽效果③（被破坏放灵摆区）的发动条件判定函数（判定是否在怪兽区域被破坏且表侧表示存在）
function c95568112.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的发动准备与可行性检查函数
function c95568112.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的效果处理（放置到灵摆区）函数
function c95568112.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己的灵摆区域表侧表示放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
