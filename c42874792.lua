--ゼンマイラビット
-- 效果：
-- 选择自己场上1只名字带有「发条」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。此外，这个效果只在这张卡在场上表侧表示存在能使用1次。
function c42874792.initial_effect(c)
	-- 效果原文内容：选择自己场上1只名字带有「发条」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。此外，这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42874792,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42874792.target)
	e1:SetOperation(c42874792.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽（表侧表示、发条族、可除外）
function c42874792.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsAbleToRemove()
end
-- 效果作用：选择满足条件的怪兽作为对象
function c42874792.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c42874792.filter(chkc) end
	-- 判断是否满足发动条件（场上存在满足条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c42874792.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c42874792.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息（除外）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果作用：将对象怪兽除外并设置返回场上的效果
function c42874792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍然在场且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 效果原文内容：选择自己场上1只名字带有「发条」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。此外，这个效果只在这张卡在场上表侧表示存在能使用1次。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCountLimit(1)
		-- 判断当前回合玩家是否为效果使用者
		if Duel.GetTurnPlayer()==tp then
			-- 判断当前阶段是否为抽卡阶段
			if Duel.GetCurrentPhase()==PHASE_DRAW then
				-- 设置返回场上的标签为当前回合数
				e1:SetLabel(Duel.GetTurnCount())
			else
				-- 设置返回场上的标签为当前回合数加2
				e1:SetLabel(Duel.GetTurnCount()+2)
			end
		else
			-- 设置返回场上的标签为当前回合数加1
			e1:SetLabel(Duel.GetTurnCount()+1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c42874792.retcon)
		e1:SetOperation(c42874792.retop)
		tc:RegisterEffect(e1)
	end
end
-- 效果作用：判断是否到回合玩家的准备阶段
function c42874792.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于设定的标签值
	return Duel.GetTurnCount()==e:GetLabel()
end
-- 效果作用：将对象怪兽返回场上
function c42874792.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽以除外形式返回场上
	Duel.ReturnToField(e:GetHandler())
	e:Reset()
end
