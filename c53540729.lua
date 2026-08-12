--ゼンマイウォリアー
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽才能发动。直到结束阶段时选择的1只怪兽的等级上升1星，攻击力上升600。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c53540729.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽才能发动。直到结束阶段时选择的1只怪兽的等级上升1星，攻击力上升600。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53540729,0))  --"等级攻击上升"
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c53540729.target)
	e1:SetOperation(c53540729.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的表侧表示的「发条」怪兽（等级大于等于1）
function c53540729.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsLevelAbove(1)
end
-- 选择满足条件的1只自己场上的表侧表示怪兽作为对象
function c53540729.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53540729.filter(chkc) end
	-- 判断是否满足发动条件：自己场上是否存在满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53540729.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足filter条件的1只自己场上的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c53540729.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 使对象怪兽在结束阶段时攻击力上升600，等级上升1
function c53540729.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使对象怪兽的攻击力上升600
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 使对象怪兽的等级上升1
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end
