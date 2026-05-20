--一陣の風
-- 效果：
-- 连锁3以后才能发动。把场上的1张魔法或者陷阱卡破坏。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
function c63516460.initial_effect(c)
	-- 连锁3以后才能发动。把场上的1张魔法或者陷阱卡破坏。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c63516460.condition)
	e1:SetTarget(c63516460.target)
	e1:SetOperation(c63516460.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c63516460.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁数是否大于等于2（即发动此卡时将成为连锁3或以上），且当前连锁中没有复数次同名卡的效果发动
	return Duel.GetCurrentChain()>1 and Duel.CheckChainUniqueness()
end
-- 过滤函数：筛选场上的魔法或陷阱卡
function c63516460.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果发动时的目标选择与检测函数
function c63516460.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c63516460.filter(chkc) and chkc~=e:GetHandler() end
	-- 在发动阶段检查场上是否存在除这张卡以外的、可作为对象的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c63516460.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张除这张卡以外的魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c63516460.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息，表示该效果包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理（发动成功后）的函数
function c63516460.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
