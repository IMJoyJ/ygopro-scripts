--SNo.39 希望皇ホープONE
-- 效果：
-- 光属性4星怪兽×3
-- 这张卡也能在自己场上的「No.39 希望皇 霍普」上面重叠来超量召唤。
-- ①：自己基本分比对方少3000以上的场合，把这张卡3个超量素材取除，把基本分支付到变成10基本分才能发动。对方场上的特殊召唤的怪兽全部破坏并除外。那之后，给与对方这个效果除外的怪兽数量×300伤害。
function c86532744.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4,3,c86532744.ovfilter,aux.Stringid(86532744,1))  --"是否在「No.39 希望皇 霍普」上面重叠超量召唤？"
	-- ①：自己基本分比对方少3000以上的场合，把这张卡3个超量素材取除，把基本分支付到变成10基本分才能发动。对方场上的特殊召唤的怪兽全部破坏并除外。那之后，给与对方这个效果除外的怪兽数量×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(86532744,0))  --"破坏并除外"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c86532744.condition)
	e1:SetCost(c86532744.cost)
	e1:SetTarget(c86532744.target)
	e1:SetOperation(c86532744.operation)
	c:RegisterEffect(e1)
end
-- 设置该怪兽的「No.」数值为39
aux.xyz_number[86532744]=39
-- 过滤用于重叠超量召唤的素材，必须是表侧表示的「No.39 希望皇 霍普」
function c86532744.ovfilter(c)
	return c:IsFaceup() and c:IsCode(84013237)
end
-- 效果①的发动条件：自己基本分比对方少3000以上
function c86532744.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的基本分是否比对方少3000以上
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-3000
end
-- 效果①的发动代价：取除3个超量素材，并支付基本分直到剩下10点
function c86532744.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己当前的生命值
	local lp=Duel.GetLP(tp)
	-- 检查是否能支付（当前生命值-10）的生命值代价，以及这张卡是否拥有至少3个超量素材
	if chk==0 then return Duel.CheckLPCost(tp,lp-10) and e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
	-- 支付生命值代价，使自己的生命值变为10
	Duel.PayLPCost(tp,lp-10)
end
-- 过滤对方场上可以被除外的特殊召唤的怪兽
function c86532744.filter(c)
	return c:IsAbleToRemove()
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果①的发动准备（检查对方场上是否存在特殊召唤的怪兽，并注册破坏与伤害的操作信息）
function c86532744.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c86532744.filter(chkc) end
	-- 检查对方场上是否存在至少1只可以被除外的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86532744.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被除外的特殊召唤的怪兽
	local sg=Duel.GetMatchingGroup(c86532744.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含目标怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置伤害操作信息，预估伤害值为破坏怪兽数量乘以300
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetCount()*300)
end
-- 过滤实际被除外的怪兽（排除因大宇宙等卡片效果重定向除外的情况）
function c86532744.ctfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
end
-- 效果①的效果处理：破坏并除外对方场上所有特殊召唤的怪兽，之后给予对方对应数量×300的伤害
function c86532744.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以被除外的特殊召唤的怪兽
	local sg=Duel.GetMatchingGroup(c86532744.filter,tp,0,LOCATION_MZONE,nil)
	-- 破坏这些怪兽并将其除外
	Duel.Destroy(sg,REASON_EFFECT,LOCATION_REMOVED)
	-- 计算实际被此效果破坏并除外的怪兽数量
	local ct=Duel.GetOperatedGroup():FilterCount(c86532744.ctfilter,nil)
	if ct>0 then
		-- 中断效果处理，使后续的伤害处理与破坏除外不视为同时进行
		Duel.BreakEffect()
		-- 给予对方实际除外怪兽数量×300的伤害
		Duel.Damage(1-tp,ct*300,REASON_EFFECT)
	end
end
