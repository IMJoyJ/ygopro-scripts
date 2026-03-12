--X・E・N・O
-- 效果：
-- 反转：在回合结束前得到对方场上1只怪兽的控制权。得到控制权的那只怪兽攻击的场合，可以直接攻击对方玩家。
function c5257687.initial_effect(c)
	-- 反转效果：在回合结束前得到对方场上1只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5257687,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c5257687.target)
	e1:SetOperation(c5257687.operation)
	c:RegisterEffect(e1)
end
-- 选择目标：选择对方场上的1只可以改变控制权的怪兽作为目标。
function c5257687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	if chk==0 then return true end
	-- 提示选择：向玩家提示“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择目标怪兽：从对方场上选择1只可改变控制权的怪兽作为目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选择的目标怪兽设置为本次效果处理的操作对象。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获得目标怪兽的控制权，并在该怪兽攻击时可直接攻击对方玩家。
function c5257687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 获得控制权：使玩家获得目标怪兽的控制权直到回合结束。
		if Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
			-- 赋予直接攻击效果：使获得控制权的怪兽在攻击时可直接攻击对方玩家。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
