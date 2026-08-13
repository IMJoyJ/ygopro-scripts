--デストラクト・ポーション
-- 效果：
-- 选择自己场上存在的1只怪兽发动。选择的怪兽破坏，自己基本分回复破坏的怪兽的攻击力的数值。
function c18739764.initial_effect(c)
	-- 选择自己场上存在的1只怪兽发动。选择的怪兽破坏，自己基本分回复破坏的怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18739764.target)
	e1:SetOperation(c18739764.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与操作信息设置：从自己场上选择1只怪兽作为对象，并根据对象是否表侧表示设置对应的破坏与回复操作信息。
function c18739764.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 在发动阶段检查自己场上是否存在至少1只可以被选择为对象的怪兽（若不存在则效果不能发动）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示信息，用于后续选择卡片的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1只怪兽作为这张卡效果的对象（取对象处理）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将本次连锁的操作信息设置为“破坏所选择的对象卡”，总计1张，供相关卡牌发动条件检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if g:GetFirst():IsFaceup() then
		-- 若选择的对象为表侧表示怪兽，则将操作信息设置为“回复基本分”，回复量为该对象当前攻击力的数值。
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
	end
end
-- 效果处理：取得对象卡，若对象仍与效果关联，则破坏该怪兽，并在破坏成功且攻击力不为0时回复相应LP。
function c18739764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:IsFaceup() and tc:GetAttack() or 0
		-- 判断对象是否确实被效果破坏，且用于回复的攻击力数值不为0；两者都满足时才执行基本分回复。
		if Duel.Destroy(tc,REASON_EFFECT)>0 and atk~=0 then
			-- 使这张卡的发动者回复对象怪兽攻击力数值的基本分。
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
