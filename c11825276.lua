--戎の忍者－冥禪
-- 效果：
-- 种族不同的「忍者」怪兽×2
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：自己的「忍者」怪兽可以直接攻击。
-- ②：只要自己场上有里侧守备表示怪兽存在，这张卡不会成为攻击对象。
-- ③：对方把效果发动时才能发动。从卡组把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制，添加融合召唤手续和接触融合程序，设置特殊召唤条件，注册直接攻击效果，注册不能成为攻击对象效果，注册诱发效果③
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足s.ffilter条件的卡作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 添加接触融合程序，要求自己场上怪兽区有可解放的卡，将这些卡解放后从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 设置该卡的特殊召唤条件，只能通过融合召唤或接触融合方式从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 使自己的「忍者」怪兽可以直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选目标为「忍者」种族的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2b))
	c:RegisterEffect(e2)
	-- 使该卡不会成为攻击对象，条件为己方场上有里侧守备表示怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	-- 设置不能成为攻击对象的过滤函数
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- 注册诱发效果③，对方发动效果时才能发动，从卡组特殊召唤1只「忍者」怪兽
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
-- 融合素材过滤函数，要求是「忍者」种族且种族不同的怪兽
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x2b) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 特殊召唤条件函数，限制只能通过融合召唤或接触融合方式从额外卡组特殊召唤
function s.splimit(e,se,sp,st)
	-- 若该卡不在额外卡组则允许召唤，否则必须通过融合召唤方式召唤
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 判断己方场上有里侧守备表示怪兽的条件函数
function s.atkcon(e)
	-- 检查己方场上有至少1张里侧守备表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 效果③发动条件函数，对方发动效果时才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 特殊召唤目标过滤函数，筛选「忍者」种族且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 效果③的发动时的判定函数，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否有满足条件的「忍者」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果③发动时的操作信息，表示将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理函数，选择并特殊召唤怪兽，若为里侧表示则确认其内容
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位，若无则不发动
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
		if g:GetFirst():IsFacedown() then
			-- 若特殊召唤的怪兽为里侧表示，则向对方确认其内容
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
