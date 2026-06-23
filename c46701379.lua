--ワルキューレ・フュンフト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「女武神」怪兽的攻击力上升除外的对方怪兽数量×200。
-- ②：自己场上有「女武神五女」以外的「女武神」怪兽存在的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
function c46701379.initial_effect(c)
	-- ①：自己场上的「女武神」怪兽的攻击力上升除外的对方怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有「女武神」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x122))
	e1:SetValue(c46701379.val)
	c:RegisterEffect(e1)
	-- ②：自己场上有「女武神五女」以外的「女武神」怪兽存在的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46701379,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46701379)
	e2:SetCondition(c46701379.tgcon)
	e2:SetTarget(c46701379.tgtg)
	e2:SetOperation(c46701379.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断除外区怪兽数量的条件
function c46701379.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升值，为除外的对方怪兽数量乘以200
function c46701379.val(e,c)
	-- 获取除外区中满足条件的怪兽数量并乘以200作为攻击力加成
	return Duel.GetMatchingGroupCount(c46701379.atkfilter,e:GetHandlerPlayer(),0,LOCATION_REMOVED,nil)*200
end
-- 过滤函数，用于判断场上的「女武神」怪兽（除女武神五女外）
function c46701379.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122) and not c:IsCode(46701379)
end
-- 判断发动条件：自己场上有「女武神五女」以外的「女武神」怪兽存在
function c46701379.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的「女武神」怪兽
	return Duel.IsExistingMatchingCard(c46701379.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于选择可送去墓地的魔法·陷阱卡
function c46701379.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 设置发动时的处理信息：从卡组选择一张魔法·陷阱卡送去墓地
function c46701379.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动效果：卡组中存在可送去墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c46701379.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为1张魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：选择并把一张魔法·陷阱卡送去墓地
function c46701379.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张魔法·陷阱卡作为目标
	local g=Duel.SelectMatchingCard(tp,c46701379.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
