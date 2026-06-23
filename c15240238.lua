--霞鳥クラウソラス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。直到回合结束时选择的怪兽的攻击力变成0，那个效果无效。
function c15240238.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。直到回合结束时选择的怪兽的攻击力变成0，那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15240238,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c15240238.target)
	e1:SetOperation(c15240238.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且攻击力大于0的怪兽
function c15240238.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 设置效果目标为对方场上表侧表示且攻击力大于0的1只怪兽
function c15240238.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c15240238.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c15240238.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择符合条件的1只对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c15240238.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，标记将使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理函数，对目标怪兽施加攻击力归零、效果无效和效果禁止
function c15240238.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 直到回合结束时选择的怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那个效果无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
