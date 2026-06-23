--賢者ケイローン
-- 效果：
-- 从手卡丢弃1张魔法卡。对方场上的1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
function c16956455.initial_effect(c)
	-- 创建效果，设置效果描述为“破坏”，分类为破坏，属性为取对象，类型为起动效果，限制一回合一次，发动位置为主怪兽区，设置费用函数、目标函数和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16956455,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c16956455.descost)
	e1:SetTarget(c16956455.destg)
	e1:SetOperation(c16956455.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的魔法卡
function c16956455.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果的费用处理函数，检查是否能丢弃一张魔法卡作为费用
function c16956455.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃魔法卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c16956455.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃一张魔法卡的操作，丢弃原因包括费用和丢弃
	Duel.DiscardHand(tp,c16956455.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断场上是否存在魔法或陷阱卡
function c16956455.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的目标选择函数，选择对方场上的魔法或陷阱卡作为目标
function c16956455.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c16956455.filter(chkc) end
	-- 检查是否满足选择对方场上魔法或陷阱卡作为目标的条件
	if chk==0 then return Duel.IsExistingTarget(c16956455.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c16956455.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定破坏效果的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，对目标卡进行破坏
function c16956455.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
