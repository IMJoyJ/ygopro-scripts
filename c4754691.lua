--水陸両用バグロス Mk－11
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上没有「海」存在的场合，这张卡的攻击力上升700，这张卡不能直接攻击。
-- ②：场上有「海」存在的场合，以水属性以外的1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c4754691.initial_effect(c)
	-- 记录本卡效果中记载的卡名「海」（卡号22702055），用于后续关联「海」的存在判定。
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
	-- 场上没有「海」存在的场合，这张卡不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(c4754691.condition)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：场上有「海」存在的场合，以水属性以外的1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
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
-- 定义①效果的条件判断函数：场上没有「海」时返回真，用于攻击力上升和不能直接攻击的效果。
function c4754691.condition(e)
	-- 返回场上不存在「海」的判定结果。
	return not Duel.IsEnvironment(22702055)
end
-- 定义②效果的发动条件函数：场上有「海」时返回真，才可发动。
function c4754691.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回场上存在「海」的判定结果。
	return Duel.IsEnvironment(22702055)
end
-- 定义②效果的对象筛选函数：对象必须是表侧表示且属性不是水属性的怪兽。
function c4754691.desfilter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_WATER)
end
-- 定义②效果的发动时处理：检查可发动性、提示选择并指定1只水属性以外的表侧表示怪兽为对象，同时设置破坏信息。
function c4754691.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4754691.desfilter(chkc) end
	-- 在效果发动合法性检查阶段，确认场上存在至少1只满足条件的表侧表示非水属性怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingTarget(c4754691.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示其选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方怪兽区域选择1只水属性以外的表侧表示怪兽，并将其登记为效果的对象。
	local g=Duel.SelectTarget(tp,c4754691.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为破坏该对象，数量为1，供后续处理及时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果的解决处理函数：取得对象，若仍与效果关联则将其破坏。
function c4754691.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
