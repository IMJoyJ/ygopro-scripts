--星神器デミウルギア
-- 效果：
-- 5星以上的怪兽3只
-- 这张卡不能作为连接素材。这个卡名的②③的效果1回合各能使用1次。
-- ①：连接召唤的这张卡不受其他怪兽的效果影响。
-- ②：已用种族和属性不同的怪兽3只为素材让这张卡连接召唤的场合才能发动。场上的其他卡全部破坏。
-- ③：对方从额外卡组把怪兽特殊召唤的场合才能发动。从卡组把1只「星遗物」怪兽特殊召唤。
function c57282724.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：5星以上的怪兽3只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLevelAbove,5),3,3)
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：连接召唤的这张卡不受其他怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(c57282724.imcon)
	e2:SetValue(c57282724.imfilter)
	c:RegisterEffect(e2)
	-- 已用种族和属性不同的怪兽3只为素材让这张卡连接召唤的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c57282724.valcheck)
	c:RegisterEffect(e3)
	-- 已用种族和属性不同的怪兽3只为素材让这张卡连接召唤的场合才能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(c57282724.regcon)
	e4:SetOperation(c57282724.regop)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
	-- ②：已用种族和属性不同的怪兽3只为素材让这张卡连接召唤的场合才能发动。场上的其他卡全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetDescription(aux.Stringid(57282724,0))
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,57282724)
	e5:SetCondition(c57282724.condition)
	e5:SetTarget(c57282724.target)
	e5:SetOperation(c57282724.operation)
	c:RegisterEffect(e5)
	-- ③：对方从额外卡组把怪兽特殊召唤的场合才能发动。从卡组把1只「星遗物」怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(57282724,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,57282725)
	e6:SetCondition(c57282724.spcon)
	e6:SetTarget(c57282724.sptg)
	e6:SetOperation(c57282724.spop)
	c:RegisterEffect(e6)
end
-- 判断自身是否为连接召唤
function c57282724.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤不受影响的效果：其他怪兽发动的效果
function c57282724.imfilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 检查连接素材是否为3只且种族和属性各不相同，并设置对应的标签值
function c57282724.valcheck(e,c)
	local g=c:GetMaterial()
	if #g==3 and g:GetClassCount(Card.GetRace)==3 and g:GetClassCount(Card.GetAttribute)==3 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查是否为连接召唤成功且素材满足种族属性各不相同的条件
function c57282724.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 给自身注册一个特定的Flag，用于标记满足效果②的发动条件
function c57282724.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(57282724,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 检查自身是否带有满足效果②发动条件的Flag
function c57282724.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(57282724)>0
end
-- 效果②的靶向处理：检查场上是否存在其他卡，并设置破坏的操作信息
function c57282724.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在除这张卡以外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除这张卡以外的所有卡
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置破坏的操作信息，包含所有将被破坏的卡及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果②的执行：获取场上除这张卡以外的所有卡并破坏
function c57282724.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有卡（若这张卡已不在场则不排除）
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 因效果破坏这些卡
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 过滤对方从额外卡组特殊召唤的怪兽
function c57282724.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 效果③的发动条件：对方从额外卡组把怪兽特殊召唤
function c57282724.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57282724.cfilter,1,nil,1-tp)
end
-- 过滤卡组中可以特殊召唤的「星遗物」怪兽
function c57282724.spfilter(c,e,tp)
	return c:IsSetCard(0xfe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的靶向处理：检查自身怪兽区域是否有空位，以及卡组中是否存在可特殊召唤的「星遗物」怪兽，并设置特殊召唤的操作信息
function c57282724.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「星遗物」怪兽
		and Duel.IsExistingMatchingCard(c57282724.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的执行：从卡组选择1只「星遗物」怪兽特殊召唤
function c57282724.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「星遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c57282724.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
