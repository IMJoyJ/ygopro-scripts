--霞鳥クラウソラス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，选择对方场上表侧表示存在的1只怪兽才能发动。直到回合结束时选择的怪兽的攻击力变成0，那个效果无效。
function c15240238.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）＋1只以上调整以外的怪兽（任意）。
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
-- 过滤函数：筛选对方场上表侧表示且当前攻击力大于0的怪兽，作为效果可选择的对象。
function c15240238.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 发动时的目标处理：确认存在合法对象，选择对方场上1只表侧攻击力大于0的怪兽，并设置使效果无效的操作信息。
function c15240238.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c15240238.filter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只满足filter条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c15240238.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出提示，要求玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家从对方场上选择1只满足filter条件的表侧表示怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c15240238.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁操作信息登记为“无效效果”，对象为所选怪兽，数量为1，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理时的操作：对对象怪兽施加攻击力变为0、效果无效化处理，这些状态均持续到回合结束。
function c15240238.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 直到回合结束时选择的怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果无效（使对象怪兽的场上效果无效化）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那个效果无效（使其效果文本无效化，且变里侧表示时重置）。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
