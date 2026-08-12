--千本ナイフ
-- 效果：
-- ①：自己场上有「黑魔术师」存在的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
function c63391643.initial_effect(c)
	-- 在卡片中记录记载了「黑魔术师」卡名的信息
	aux.AddCodeList(c,46986414)
	-- ①：自己场上有「黑魔术师」存在的场合，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c63391643.condition)
	e1:SetTarget(c63391643.target)
	e1:SetOperation(c63391643.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名为「黑魔术师」的卡
function c63391643.cfilter(c)
	return c:IsFaceup() and c:IsCode(46986414)
end
-- 发动条件：自己场上存在「黑魔术师」
function c63391643.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「黑魔术师」
	return Duel.IsExistingMatchingCard(c63391643.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动时的对象选择与处理
function c63391643.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动检测：检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的怪兽
function c63391643.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该对象怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
