--デストラクト・ポーション
-- 效果：
-- 选择自己场上存在的1只怪兽发动。选择的怪兽破坏，自己基本分回复破坏的怪兽的攻击力的数值。
function c18739764.initial_effect(c)
	-- 效果原文内容：选择自己场上存在的1只怪兽发动。选择的怪兽破坏，自己基本分回复破坏的怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18739764.target)
	e1:SetOperation(c18739764.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：设置效果目标选择函数
function c18739764.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 效果作用：检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上一只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if g:GetFirst():IsFaceup() then
		-- 效果作用：设置回复LP效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
	end
end
-- 效果原文内容：选择自己场上存在的1只怪兽发动。选择的怪兽破坏，自己基本分回复破坏的怪兽的攻击力的数值。
function c18739764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:IsFaceup() and tc:GetAttack() or 0
		-- 效果作用：判断破坏是否成功且攻击力不为0
		if Duel.Destroy(tc,REASON_EFFECT)>0 and atk~=0 then
			-- 效果作用：使玩家回复对应攻击力数值的LP
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
