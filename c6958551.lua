--シャドー・トゥーン
-- 效果：
-- 「影子卡通」在1回合只能发动1张。
-- ①：自己场上有「卡通世界」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只表侧表示怪兽的攻击力数值的伤害。
function c6958551.initial_effect(c)
	-- 记录该卡片记有「卡通世界」（卡号15259703）的事实。
	aux.AddCodeList(c,15259703)
	-- 「影子卡通」在1回合只能发动1张。①：自己场上有「卡通世界」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。给与对方那只表侧表示怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,6958551+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c6958551.condition)
	e1:SetTarget(c6958551.target)
	e1:SetOperation(c6958551.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名为「卡通世界」的卡。
function c6958551.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果发动条件：自己场上存在「卡通世界」。
function c6958551.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「卡通世界」。
	return Duel.IsExistingMatchingCard(c6958551.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：表侧表示且攻击力大于0的怪兽。
function c6958551.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果发动时的目标选择与处理。
function c6958551.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c6958551.filter(chkc) end
	-- 检查对方场上是否存在可作为对象的表侧表示且攻击力大于0的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c6958551.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示且攻击力大于0的怪兽作为对象。
	local g=Duel.SelectTarget(tp,c6958551.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：给与对方相当于所选怪兽攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果处理的执行函数。
function c6958551.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 给与对方该怪兽攻击力数值的伤害。
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end
