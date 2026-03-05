--タイフーン
-- 效果：
-- 对方场上有魔法·陷阱卡2张以上存在，自己场上没有魔法·陷阱卡存在的场合，这张卡的发动从手卡也能用。
-- ①：以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
function c14883228.initial_effect(c)
	-- ①：以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c14883228.target)
	e1:SetOperation(c14883228.activate)
	c:RegisterEffect(e1)
	-- 对方场上有魔法·陷阱卡2张以上存在，自己场上没有魔法·陷阱卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14883228,0))  --"适用「台风」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c14883228.handcon)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断一张卡是否为魔法或陷阱类型
function c14883228.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断是否满足从手牌发动条件的函数
function c14883228.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在魔法或陷阱卡
	return not Duel.IsExistingMatchingCard(c14883228.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少2张魔法或陷阱卡
		and Duel.IsExistingMatchingCard(c14883228.cfilter,tp,0,LOCATION_ONFIELD,2,nil)
end
-- 过滤函数，用于判断一张卡是否为表侧表示的魔法或陷阱卡
function c14883228.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理时的target阶段函数
function c14883228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c14883228.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件，即场上是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingTarget(c14883228.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择满足条件的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,c14883228.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的activate阶段函数
function c14883228.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
