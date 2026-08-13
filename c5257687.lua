--X・E・N・O
-- 效果：
-- 反转：在回合结束前得到对方场上1只怪兽的控制权。得到控制权的那只怪兽攻击的场合，可以直接攻击对方玩家。
function c5257687.initial_effect(c)
	-- 反转：在回合结束前得到对方场上1只怪兽的控制权。得到控制权的那只怪兽攻击的场合，可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5257687,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c5257687.target)
	e1:SetOperation(c5257687.operation)
	c:RegisterEffect(e1)
end
-- 反转效果发动时进行取对象处理：检查对象是否为对方场上主要怪兽区且可改变控制权的怪兽；无追加发动条件；随后提示选择并选定1只符合条件的对方怪兽作为效果对象，同时设置本次操作信息为改变控制权。
function c5257687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return true end
	-- 向发动者显示选择提示消息，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上主要怪兽区选择1只可改变控制权的怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前效果处理的操作信息：分类为改变控制权，对象为已选择的1只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理反转效果：获取效果对象怪兽；若对象仍与效果关联，则尝试将其控制权转移给发动者直到结束阶段；若转移成功，再为该怪兽赋予可以直接攻击的效果。
function c5257687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取反转效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 尝试将对象怪兽的控制权转移给发动者，持续到结束阶段；若转移成功（返回值非0）则继续执行后续赋予直接攻击效果的步骤。
		if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
			-- 得到控制权的那只怪兽攻击的场合，可以直接攻击对方玩家。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
