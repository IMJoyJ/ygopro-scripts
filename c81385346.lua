--スタンピング・クラッシュ
-- 效果：
-- 自己的场上有表侧表示的龙族怪兽存在时才能发动。破坏场上的1张魔法·陷阱卡，给与那张被破坏的卡的控制者500分的伤害。
function c81385346.initial_effect(c)
	-- 自己的场上有表侧表示的龙族怪兽存在时才能发动。破坏场上的1张魔法·陷阱卡，给与那张被破坏的卡的控制者500分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c81385346.condition)
	e1:SetTarget(c81385346.target)
	e1:SetOperation(c81385346.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的龙族怪兽
function c81385346.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 发动条件：自己场上存在表侧表示的龙族怪兽
function c81385346.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的龙族怪兽
	return Duel.IsExistingMatchingCard(c81385346.filter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c81385346.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的目标选择与操作信息设置
function c81385346.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c81385346.filter2(chkc) and chkc~=e:GetHandler() end
	-- 在发动时，检查场上是否存在除这张卡以外的魔法·陷阱卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c81385346.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c81385346.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与被破坏卡片的控制者500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),500)
end
-- 效果处理：破坏作为对象的卡，并给与该卡控制者500点伤害
function c81385346.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local p=tc:GetControler()
		-- 破坏目标卡片，若未成功破坏则不进行后续处理
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- 给与被破坏卡片的控制者500点伤害
		Duel.Damage(p,500,REASON_EFFECT)
	end
end
