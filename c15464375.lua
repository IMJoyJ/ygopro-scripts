--水月のアデュラリア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升场上的表侧表示的魔法·陷阱卡数量×600。
-- ③：把自己的魔法与陷阱区域2张表侧表示卡送去墓地才能发动。从卡组把1只4星以下的怪兽送去墓地。
function c15464375.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15464375+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15464375.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升场上的表侧表示的魔法·陷阱卡数量×600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(c15464375.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：把自己的魔法与陷阱区域2张表侧表示卡送去墓地才能发动。从卡组把1只4星以下的怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,15464375)
	e4:SetCost(c15464375.tgcost)
	e4:SetTarget(c15464375.tgtg)
	e4:SetOperation(c15464375.tgop)
	c:RegisterEffect(e4)
end
-- 判断魔陷区的卡是否为表侧表示且不在场地魔法格（序号<5），作为①特殊召唤所需的自方魔陷区表侧表示卡的过滤条件。
function c15464375.spcfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- ①特殊召唤规则的条件：若c为空则规则可用；否则要求自己的主要怪兽区有空位，且自己魔陷区存在至少1张满足spcfilter的表侧表示卡。
function c15464375.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 自己的主要怪兽区可用空格数大于0（即存在可特殊召唤的空位）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 自己魔陷区存在至少1张符合spcfilter的表侧表示卡。
		and Duel.IsExistingMatchingCard(c15464375.spcfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 计算攻击力上升值时，过滤出场上表侧表示的魔法·陷阱卡（所有魔法/陷阱卡类型）。
function c15464375.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- 攻击力上升值计算函数：统计控制者场上表侧表示的魔法·陷阱卡数量，乘以600。
function c15464375.atkval(e,c)
	-- 返回场上表侧表示的魔法·陷阱卡数量×600。
	return Duel.GetMatchingGroupCount(c15464375.atkfilter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*600
end
-- 作为③代价而选择的卡需满足：表侧表示、可以作为代价送去墓地、且位于主要魔陷区（不选场地格）。
function c15464375.cfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- ③发动代价：检查是否存在2张满足条件的自方魔陷区表侧表示卡，若存在则选择2张送去墓地作为代价。
function c15464375.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认（chk==0）时，检查自方魔陷区是否存在至少2张满足cfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c15464375.cfilter,tp,LOCATION_SZONE,0,2,nil) end
	-- 向发动方显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 发动方从自己的魔陷区选择2张满足cfilter的表侧表示卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c15464375.cfilter,tp,LOCATION_SZONE,0,2,2,nil)
	-- 将选中的2张卡以代价（REASON_COST）形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③从卡组送墓的过滤条件：卡为4星以下怪兽，且可以被效果送去墓地。
function c15464375.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- ③发动目标判断：确认卡组存在符合条件的4星以下怪兽，并设置本次操作信息为从卡组送去墓地。
function c15464375.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否有至少1只4星以下且可送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15464375.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本次效果处理会将1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只4星以下怪兽送去墓地。
function c15464375.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动方显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 发动方从卡组选择1只满足tgfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,c15464375.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果（REASON_EFFECT）形式送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
