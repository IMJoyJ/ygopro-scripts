--ダークエンド・ドラゴン
-- 效果：
-- 调整＋调整以外的暗属性怪兽1只以上
-- 1回合1次，可以把这张卡的攻击力·守备力下降500，对方场上存在的1只怪兽送去墓地。
function c88643579.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的暗属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡的攻击力·守备力下降500，对方场上存在的1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88643579,0))  --"对方场上存在的1只怪兽送去墓地。"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c88643579.target)
	e1:SetOperation(c88643579.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判定与对象选择，判定自身攻防是否不低于500且对方场上有可送去墓地的怪兽
function c88643579.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	if chk==0 then return c:GetAttack()>=500 and c:GetDefense()>=500
		-- 判定对方场上是否存在可以送去墓地的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端显示提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只可以送去墓地的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：使自身攻击力与守备力下降500，并将作为对象的怪兽送去墓地
function c88643579.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetAttack()>=500 and c:GetDefense()>=500 then
		-- 可以把这张卡的攻击力·守备力下降500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		if tc and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) and not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 将目标怪兽因效果送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
