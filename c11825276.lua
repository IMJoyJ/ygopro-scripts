--戎の忍者－冥禪
-- 效果：
-- 种族不同的「忍者」怪兽×2
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：自己的「忍者」怪兽可以直接攻击。
-- ②：只要自己场上有里侧守备表示怪兽存在，这张卡不会成为攻击对象。
-- ③：对方把效果发动时才能发动。从卡组把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求使用2个满足条件的「忍者」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 添加接触融合程序，允许通过解放自己场上的符合条件的怪兽从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- ③：对方把效果发动时才能发动。从卡组把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- ①：自己的「忍者」怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为所有「忍者」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2b))
	c:RegisterEffect(e2)
	-- ②：只要自己场上有里侧守备表示怪兽存在，这张卡不会成为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	-- 设置效果值为不会成为攻击对象的过滤函数
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- ③：对方把效果发动时才能发动。从卡组把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数，确保种族不同
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x2b) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 特殊召唤限制函数，用于限制只能通过融合召唤从额外卡组特殊召唤
function s.splimit(e,se,sp,st)
	-- 如果卡片不在额外卡组则不生效，否则调用融合限制函数
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 攻击条件判断函数，用于判断是否满足效果发动条件
function s.atkcon(e)
	-- 检查自己场上是否存在里侧守备表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤发动条件函数，用于判断是否为对方发动效果时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 特殊召唤目标过滤函数，筛选可以特殊召唤的「忍者」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 特殊召唤发动时的处理函数，用于设置发动信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，包括是否有足够的召唤位置和卡组中是否有符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的「忍者」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置发动信息，表示将从卡组特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤处理函数，用于执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
		if g:GetFirst():IsFacedown() then
			-- 确认对方能看到被特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
