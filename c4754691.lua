--水陸両用バグロス Mk－11
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上没有「海」存在的场合，这张卡的攻击力上升700，这张卡不能直接攻击。
-- ②：场上有「海」存在的场合，以水属性以外的1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c4754691.initial_effect(c)
	-- 记录该卡牌具有「海」这张卡片的编号，用于后续判断场地状态
	aux.AddCodeList(c,22702055)
	-- 场上没有「海」存在的场合，这张卡的攻击力上升700
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c4754691.condition)
	e1:SetValue(700)
	c:RegisterEffect(e1)
	-- 场上没有「海」存在的场合，这张卡不能直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(c4754691.condition)
	c:RegisterEffect(e2)
	-- 场上有「海」存在的场合，以水属性以外的1只表侧表示怪兽为对象才能发动。那只怪兽破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4754691,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,4754691)
	e3:SetCondition(c4754691.descon)
	e3:SetTarget(c4754691.destg)
	e3:SetOperation(c4754691.desop)
	c:RegisterEffect(e3)
end
-- 判断当前是否处于无「海」的场地状态
function c4754691.condition(e)
	-- 若当前没有「海」场地卡存在则返回true
	return not Duel.IsEnvironment(22702055)
end
-- 判断当前是否处于有「海」的场地状态
function c4754691.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前有「海」场地卡存在则返回true
	return Duel.IsEnvironment(22702055)
end
-- 筛选条件：怪兽必须表侧表示且属性不是水属性
function c4754691.desfilter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_WATER)
end
-- 设置效果目标选择函数，检查是否有符合条件的目标怪兽并进行选择
function c4754691.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4754691.desfilter(chkc) end
	-- 检测是否存在满足破坏条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c4754691.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择一只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c4754691.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明本次效果将破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果处理函数，对选定的目标怪兽进行破坏
function c4754691.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
