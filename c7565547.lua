--力の集約
-- 效果：
-- 选择场上表侧表示存在的1只怪兽发动。场上存在的全部装备卡给选择的怪兽装备。对象不正确的装备卡破坏。
function c7565547.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽发动。场上存在的全部装备卡给选择的怪兽装备。对象不正确的装备卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c7565547.target)
	e1:SetOperation(c7565547.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上表侧表示的装备卡
function c7565547.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 效果发动时的合法性检查与对象选择处理
function c7565547.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段，检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且检查场上是否存在至少一张表侧表示的装备卡
		and Duel.IsExistingMatchingCard(c7565547.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的怪兽作为本效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：尝试将场上所有装备卡装备给目标怪兽，若装备对象不合法则放入待破坏组，最后执行装备完成并破坏不合法的装备卡
function c7565547.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为本效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local dg=Group.CreateGroup()
	-- 获取场上所有的表侧表示装备卡
	local g=Duel.GetMatchingGroup(c7565547.eqfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	local ec=g:GetFirst()
	while ec do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and ec:CheckEquipTarget(tc) then
			-- 将当前的装备卡装备给目标怪兽
			Duel.Equip(tp,ec,tc,false,false)
		else
			dg:AddCard(ec)
		end
		ec=g:GetNext()
	end
	-- 完成装备卡装备流程，触发相关时点
	Duel.EquipComplete()
	-- 因效果破坏所有装备对象不合法的装备卡
	Duel.Destroy(dg,REASON_EFFECT)
end
