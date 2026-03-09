--シューティング・スター
-- 效果：
-- ①：场上有「星尘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c47264717.initial_effect(c)
	-- 效果原文内容：①：场上有「星尘」怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,0x11e0)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c47264717.condition)
	e1:SetTarget(c47264717.target)
	e1:SetOperation(c47264717.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测场上是否存在表侧表示的「星尘」怪兽
function c47264717.cfilter(c)
	return c:IsSetCard(0xa3) and c:IsFaceup()
end
-- 条件函数，判断场上有无「星尘」怪兽存在
function c47264717.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看，自己的主要怪兽区和对方的主要怪兽区是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c47264717.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 目标选择函数，设置效果的目标为场上任意一张非自身卡片
function c47264717.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件，即场上是否存在至少1张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息为破坏效果，目标为所选卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动函数，执行破坏操作
function c47264717.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
