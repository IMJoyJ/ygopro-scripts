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
	-- 设置该攻击力增减效果的影响对象：自己场上所有卡名含有「女武神」字段的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x122))
	e1:SetValue(c46701379.val)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「女武神五女」以外的「女武神」怪兽存在的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
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
-- 定义过滤条件：卡为表侧表示且为怪兽卡（此处用于从对方除外区中统计符合条件的怪兽）。
function c46701379.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升数值：统计对方除外区中表侧表示的怪兽数量，乘以200作为攻击力增加值。
function c46701379.val(e,c)
	-- 返回对方除外区中表侧表示怪兽的数量×200，作为此永续效果给予的攻击力上升值。
	return Duel.GetMatchingGroupCount(c46701379.atkfilter,e:GetHandlerPlayer(),0,LOCATION_REMOVED,nil)*200
end
-- 定义②效果的发动条件过滤器：场上存在表侧表示、属于「女武神」字段、且卡名不是「女武神五女」的怪兽。
function c46701379.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122) and not c:IsCode(46701379)
end
-- ②效果的发动条件：自己场上有满足条件的「女武神」怪兽（即「女武神五女」以外的表侧表示「女武神」怪兽）存在。
function c46701379.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足cfilter条件的「女武神」怪兽。
	return Duel.IsExistingMatchingCard(c46701379.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义②效果从卡组选择送去墓地的卡片的过滤条件：卡为魔法·陷阱卡且可以送去墓地。
function c46701379.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- ②效果发动时的目标处理：若为发动合法性检查（chk==0），确认卡组存在可送去墓地的魔法·陷阱卡；若合法，则将本次操作标记为从卡组将1张卡送去墓地。
function c46701379.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点的合法性检查：确认自己卡组中存在至少1张满足tgfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46701379.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：效果分类为送去墓地，预定从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时：从卡组选择1张魔法·陷阱卡送去墓地。
function c46701379.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家弹出选择提示“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从自己的卡组中选出1张满足tgfilter条件的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c46701379.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
