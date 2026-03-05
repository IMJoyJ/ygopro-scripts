--Sin パラダイム・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。场上没有「罪 范式龙」存在的场合，从额外卡组把1只「罪」怪兽除外的场合才能特殊召唤。
-- ①：场上没有「罪 世界」存在的场合这张卡破坏。
-- ②：1回合1次，从卡组把1张「罪」卡送去墓地才能发动。除外的1只自己的8星同调怪兽回到额外卡组。那之后，可以把那只怪兽从额外卡组特殊召唤。这个回合，自己不用「罪」怪兽不能攻击。
function c16958382.initial_effect(c)
	-- 记录该卡具有「罪 范式龙」的卡名代码
	aux.AddCodeList(c,27564031)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。场上没有「罪 范式龙」存在的场合，从额外卡组把1只「罪」怪兽除外的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 特殊召唤规则：从额外卡组把1只「罪」怪兽除外的场合才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16958382.spcon)
	e1:SetTarget(c16958382.sptg)
	e1:SetOperation(c16958382.spop)
	c:RegisterEffect(e1)
	-- 场上没有「罪 世界」存在的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c16958382.descon)
	c:RegisterEffect(e2)
	-- 1回合1次，从卡组把1张「罪」卡送去墓地才能发动。除外的1只自己的8星同调怪兽回到额外卡组。那之后，可以把那只怪兽从额外卡组特殊召唤。这个回合，自己不用「罪」怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16958382,0))
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c16958382.cost)
	e3:SetTarget(c16958382.target)
	e3:SetOperation(c16958382.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回是否为「罪」卡且能除外作为费用
function c16958382.spfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数：返回是否具有效果48829461且能除外作为费用且场上怪兽区有空位
function c16958382.spfilter2(c,tp)
	-- 返回是否具有效果48829461且能除外作为费用且场上怪兽区有空位
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数：返回是否为「罪 范式龙」且表侧表示
function c16958382.codefilter(c)
	return c:IsCode(16958382) and c:IsFaceup()
end
-- 特殊召唤条件函数：检查是否满足特殊召唤条件
function c16958382.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有怪兽区空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家额外卡组是否存在「罪」怪兽
		and Duel.IsExistingMatchingCard(c16958382.spfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 检查玩家场上或墓地是否存在具有效果48829461的「罪」怪兽
	local b2=Duel.IsExistingMatchingCard(c16958382.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	-- 返回是否满足特殊召唤条件
	return (b1 or b2) and not Duel.IsExistingMatchingCard(c16958382.codefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤目标选择函数：选择要除外的卡
function c16958382.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 检查玩家场上是否有怪兽区空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取玩家额外卡组中满足条件的「罪」怪兽
		local g1=Duel.GetMatchingGroup(c16958382.spfilter,tp,LOCATION_EXTRA,0,nil)
		g:Merge(g1)
	end
	-- 获取玩家场上或墓地中满足条件的「罪」怪兽
	local g2=Duel.GetMatchingGroup(c16958382.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		if g2:IsContains(tc) then
			local te=tc:IsHasEffect(48829461,tp)
			te:UseCountLimit(tp)
		end
		return true
	else return false end
end
-- 特殊召唤操作函数：将选中的卡除外
function c16958382.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将目标卡除外
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 破坏条件函数：检查是否满足破坏条件
function c16958382.descon(e)
	-- 返回是否不处于「罪 世界」环境
	return not Duel.IsEnvironment(27564031)
end
-- 过滤函数：返回是否为「罪」卡且能送去墓地作为费用
function c16958382.cfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToGraveAsCost()
end
-- 效果费用函数：选择并送去墓地1张「罪」卡
function c16958382.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否存在「罪」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16958382.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择玩家卡组中1张「罪」卡
	local g=Duel.SelectMatchingCard(tp,c16958382.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：返回是否为8星同调怪兽且能返回额外卡组
function c16958382.filter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(8) and c:IsFaceup() and c:IsAbleToExtra()
end
-- 效果目标函数：检查是否存在满足条件的卡
function c16958382.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16958382.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置效果操作信息：将满足条件的卡返回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理函数：选择并返回额外卡组，然后特殊召唤
function c16958382.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c16958382.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	-- 检查是否成功返回额外卡组且在额外卡组
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		-- 检查是否有足够的特殊召唤空位且能特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 询问玩家是否特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(16958382,1)) then  --"是否特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将目标卡特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置效果：本回合自己不能攻击除「罪」怪兽外的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c16958382.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果：使对方不能攻击
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制目标函数：返回是否不是「罪」怪兽
function c16958382.atktg(e,c)
	return not c:IsSetCard(0x23)
end
