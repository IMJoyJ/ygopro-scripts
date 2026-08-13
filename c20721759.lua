--ヘイト・クレバス
-- 效果：
-- 自己场上存在的怪兽1只被对方的卡的效果破坏送去墓地时，选择对方场上存在的1只怪兽送去墓地，给与对方基本分那个原本攻击力数值的伤害。
function c20721759.initial_effect(c)
	-- 自己场上存在的怪兽1只被对方的卡的效果破坏送去墓地时，选择对方场上存在的1只怪兽送去墓地，给与对方基本分那个原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c20721759.condition)
	e1:SetTarget(c20721759.target)
	e1:SetOperation(c20721759.operation)
	c:RegisterEffect(e1)
end
-- 条件判定：触发事件中的怪兽必须是1只，且该怪兽是从我方怪兽区、由我方控制的状态下被对方玩家的卡的效果破坏并送去墓地（排除战斗破坏和己方效果），满足发动条件。
function c20721759.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return rp==1-tp and eg:GetCount()==1 and ec:IsPreviousLocation(LOCATION_MZONE) and ec:IsPreviousControler(tp)
		and ec:IsReason(REASON_DESTROY) and ec:IsReason(REASON_EFFECT)
end
-- 发动时的目标选择处理：从对方场上选择1只怪兽作为效果对象，同时设置将对象送去墓地及造成其原本攻击力伤害的操作信息。
function c20721759.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动合法性检查：确认对方场上有至少1只可以成为对象的怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示消息“请选择要送去墓地的卡”，供玩家选择时参考。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方场上选择1只怪兽，并将其登记为本效果的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将把选中的对象送去墓地，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置操作信息：本次效果将给对方造成伤害，数值为所选怪兽的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 效果处理：将对象怪兽送去墓地；若怪兽因此存在于墓地，则给对方造成与该怪兽原本攻击力相同数值的伤害（若原本攻击力为负则按0）。
function c20721759.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 以效果原因将对象怪兽送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
	if not tc:IsLocation(LOCATION_GRAVE) then return end
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	-- 给对方玩家造成atk点效果伤害（atk为对象怪兽的原本攻击力，负数按0计算）。
	Duel.Damage(1-tp,atk,REASON_EFFECT)
end
