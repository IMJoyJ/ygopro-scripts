--パンデミック・ドラゴン
-- 效果：
-- ①：1回合1次，支付100的倍数的基本分才能发动。这张卡以外的场上的表侧表示怪兽的攻击力下降因为这个效果发动而支付的基本分数值。
-- ②：1回合1次，以持有这张卡的攻击力以下的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡被战斗·效果破坏的场合发动。场上的全部表侧表示怪兽的攻击力下降1000。
function c68299524.initial_effect(c)
	-- ①：1回合1次，支付100的倍数的基本分才能发动。这张卡以外的场上的表侧表示怪兽的攻击力下降因为这个效果发动而支付的基本分数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(68299524,0))  --"攻击力下降"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c68299524.cost)
	e1:SetOperation(c68299524.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以持有这张卡的攻击力以下的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68299524,1))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c68299524.destg)
	e2:SetOperation(c68299524.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合发动。场上的全部表侧表示怪兽的攻击力下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68299524,2))  --"全部怪兽攻击力下降1000"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c68299524.atkcon)
	e3:SetOperation(c68299524.atkop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且攻击力在100以上的怪兽
function c68299524.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(100)
end
-- 效果①的发动代价（Cost）判定与处理函数
function c68299524.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付至少100点基本分
	if chk==0 then return Duel.CheckLPCost(tp,100,true)
		-- 检查场上是否存在至少1只这张卡以外的满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c68299524.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c68299524.filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local tg,atk=g:GetMaxGroup(Card.GetAttack)
	-- 计算可支付基本分的最大上限值（取自身基本分、场上怪兽最大攻击力与25500的最小值）
	local maxc=math.min(Duel.GetLP(tp),atk,25500)
	local ct=math.floor(maxc/100)
	local t={}
	for i=1,ct do
		t[i]=i*100
	end
	-- 让玩家选择并宣言要支付的基本分数值
	local cost=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 玩家支付宣言的基本分数值
	Duel.PayLPCost(tp,cost,true)
	e:SetLabel(cost)
end
-- 效果①的效果处理（Operation）函数
function c68299524.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的表侧表示怪兽组
	local g=Duel.GetMatchingGroup(c68299524.filter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	local val=e:GetLabel()
	while tc do
		-- 这张卡以外的场上的表侧表示怪兽的攻击力下降因为这个效果发动而支付的基本分数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤场上表侧表示且攻击力在指定数值以下的怪兽
function c68299524.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果②的对象选择与发动准备（Target）函数
function c68299524.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68299524.desfilter(chkc,c:GetAttack()) end
	-- 检查场上是否存在至少1只持有这张卡攻击力以下攻击力的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c68299524.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只持有这张卡攻击力以下攻击力的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68299524.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetAttack())
	-- 设置效果处理信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c68299524.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查这张卡是否是被战斗或效果破坏
function c68299524.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 效果③的效果处理（Operation）函数
function c68299524.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的表侧表示怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部表侧表示怪兽的攻击力下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
