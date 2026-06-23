--水月のアデュラリア
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升场上的表侧表示的魔法·陷阱卡数量×600。
-- ③：把自己的魔法与陷阱区域2张表侧表示卡送去墓地才能发动。从卡组把1只4星以下的怪兽送去墓地。
function c15464375.initial_effect(c)
	-- ①：自己的魔法与陷阱区域有表侧表示卡存在的场合，这张卡可以从手卡特殊召唤。
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
	-- ③：把自己的魔法与陷阱区域2张表侧表示卡送去墓地才能发动。从卡组把1只4星以下的怪兽送去墓地。
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
-- 过滤函数，用于判断魔法与陷阱区域中是否有表侧表示的卡。
function c15464375.spcfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 特殊召唤条件函数，判断是否满足从手卡特殊召唤的条件。
function c15464375.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家魔法与陷阱区域是否有至少1张表侧表示的卡。
		and Duel.IsExistingMatchingCard(c15464375.spcfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- 过滤函数，用于判断场上是否有表侧表示的魔法或陷阱卡。
function c15464375.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- 计算攻击力的函数，根据场上的魔法与陷阱卡数量计算攻击力提升值。
function c15464375.atkval(e,c)
	-- 获取场上满足条件的魔法与陷阱卡数量并乘以600作为攻击力提升值。
	return Duel.GetMatchingGroupCount(c15464375.atkfilter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*600
end
-- 过滤函数，用于判断魔法与陷阱区域中是否有可作为代价送去墓地的表侧表示卡。
function c15464375.cfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- 效果发动时的处理函数，用于选择并送入墓地2张魔法与陷阱区域的表侧表示卡。
function c15464375.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即魔法与陷阱区域是否有至少2张可送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c15464375.cfilter,tp,LOCATION_SZONE,0,2,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择2张满足条件的卡并将其送入墓地。
	local g=Duel.SelectMatchingCard(tp,c15464375.cfilter,tp,LOCATION_SZONE,0,2,2,nil)
	-- 将选中的卡以REASON_COST原因送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于判断卡组中是否有4星以下且可送去墓地的怪兽。
function c15464375.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- 效果发动时的处理函数，用于检查卡组中是否有满足条件的怪兽。
function c15464375.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即卡组中是否有至少1只4星以下的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15464375.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动时的操作信息，表示将从卡组送去墓地1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，用于从卡组选择并送入墓地1只4星以下的怪兽。
function c15464375.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c15464375.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以REASON_EFFECT原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
