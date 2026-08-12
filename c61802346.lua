--ブリザード・ドラゴン
-- 效果：
-- 选择对方场上存在的1只怪兽。选择怪兽直到下次对方回合的结束阶段时，不能作表示形式的改变和攻击宣言。这个效果1回合只能使用1次。
function c61802346.initial_effect(c)
	-- 选择对方场上存在的1只怪兽。选择怪兽直到下次对方回合的结束阶段时，不能作表示形式的改变和攻击宣言。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61802346,0))  --"行动限制"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c61802346.target)
	e1:SetOperation(c61802346.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动阶段，进行发动条件检查并选择对方场上的1只怪兽作为效果对象。
function c61802346.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动效果的准备阶段，检查对方场上是否存在可以作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，提示其选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上的1只怪兽作为效果对象，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果的处理阶段，如果选择的对象依然合法，则对其适用不能攻击和不能改变表示形式的效果。
function c61802346.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 直到下次对方回合的结束阶段时，不能作...攻击宣言
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 直到下次对方回合的结束阶段时，不能作表示形式的改变...
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end
