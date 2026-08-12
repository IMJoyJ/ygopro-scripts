--海竜神の怒り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上有「海」存在的场合，以最多有自己场上的原本等级是5星以上的水属性怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。直到下个回合的结束时，那些怪兽存在过的区域不能使用。
function c82685480.initial_effect(c)
	-- 将「海」加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,22702055)
	-- ①：场上有「海」存在的场合，以最多有自己场上的原本等级是5星以上的水属性怪兽数量的对方场上的怪兽为对象才能发动。那些怪兽破坏。直到下个回合的结束时，那些怪兽存在过的区域不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,82685480+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c82685480.condition)
	e1:SetTarget(c82685480.target)
	e1:SetOperation(c82685480.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数
function c82685480.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「海」
	return Duel.IsEnvironment(22702055)
end
-- 过滤自己场上表侧表示、原本等级5星以上的水属性怪兽
function c82685480.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:GetOriginalLevel()>=5
end
-- 定义效果发动的目标选择与检测函数
function c82685480.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 获取自己场上满足条件的原本等级5星以上的水属性怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c82685480.filter,tp,LOCATION_MZONE,0,nil)
	-- 在发动检测阶段，检查自己场上是否有符合条件的怪兽，且对方场上是否存在至少1只可以作为对象的怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择最多等同于自己场上原本等级5星以上水属性怪兽数量的对方场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置连锁的操作信息，表明此效果的处理为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理的执行函数
function c82685480.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 将对象怪兽因效果破坏，若没有怪兽被破坏则结束处理
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	local val=0
	-- 获取实际被破坏并移动位置的卡片组
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 计算被破坏怪兽原本所在区域的全局位掩码，并进行按位或运算累加
		val=val|aux.SequenceToGlobal(tc:GetPreviousControler(),LOCATION_MZONE,tc:GetPreviousSequence())
		tc=og:GetNext()
	end
	-- 直到下个回合的结束时，那些怪兽存在过的区域不能使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(val)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 在全局注册该区域禁用效果
	Duel.RegisterEffect(e1,tp)
end
