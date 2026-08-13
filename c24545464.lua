--シンクロン・リフレクト
-- 效果：
-- 自己场上表侧表示存在的同调怪兽成为攻击对象时才能发动。那个攻击无效，对方场上存在的1只怪兽破坏。
function c24545464.initial_effect(c)
	-- 自己场上表侧表示存在的同调怪兽成为攻击对象时才能发动。那个攻击无效，对方场上存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c24545464.condition)
	e1:SetTarget(c24545464.target)
	e1:SetOperation(c24545464.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：取得成为攻击对象的怪兽，确认其控制者为自己、表侧表示且为同调怪兽，即满足“自己场上表侧表示存在的同调怪兽成为攻击对象”的发动条件。
function c24545464.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsType(TYPE_SYNCHRO)
end
-- 发动时的目标选择与操作信息设置：选择对方场上的1只怪兽作为破坏对象，并将该破坏信息登记到连锁，以便后续处理和其他效果联动。
function c24545464.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动合法性的非连锁检查：确认对方场上存在至少1只可选择为对象的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从对方场上选择1只怪兽作为效果对象，并通过SelectTarget将该对象登记到当前连锁。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息：效果将破坏所选的1只怪兽，供规则系统记录及后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：无效那次攻击，并破坏发动时选择的对方场上的1只怪兽。
function c24545464.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前那次攻击无效化。
	Duel.NegateAttack()
	-- 取得效果发动时选择并登记的对方场上的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该对象怪兽；若对象已不与该效果关联（如离场导致联系重置）则不处理。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
