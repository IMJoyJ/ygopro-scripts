--戎の忍者－冥禪
-- 效果：
-- 种族不同的「忍者」怪兽×2
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：自己的「忍者」怪兽可以直接攻击。
-- ②：只要自己场上有里侧守备表示怪兽存在，这张卡不会成为攻击对象。
-- ③：对方把效果发动时才能发动。从卡组把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册这张卡的全部效果：召唤条件限制、融合/接触融合召唤手续、①直接攻击、②攻击对象免疫、③对方发动效果时从卡组特召忍者的诱发即时效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用2只满足s.ffilter的怪兽（「忍者」字段且种族互不相同）作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 为这张卡添加接触融合手续：把自己场上可解放的怪兽解放作为素材，从额外卡组特殊召唤这张卡；素材处理为解放，原因视为特殊召唤的融合素材。
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤。
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
	-- 设定该效果影响的对象为“自己场上拥有「忍者」字段的怪兽”，使其获得直接攻击的能力。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2b))
	c:RegisterEffect(e2)
	-- ②：只要自己场上有里侧守备表示怪兽存在，这张卡不会成为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	-- 将效果值设为内置的‘不能成为攻击对象’判定函数，使这张卡对所有不免疫该效果的卡都不能被选为攻击对象（在适用条件下）。
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	-- ③：对方把效果发动时才能发动。从卡组把1只「忍者」怪兽表侧守备表示或者里侧守备表示特殊召唤。这个卡名的③的效果1回合只能使用1次。
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
-- 融合素材过滤函数：素材必须是「忍者」字段怪兽，并且若已选定素材，其种族不能与已选素材中任何怪兽的种族相同。
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x2b) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 特殊召唤限制函数：这张卡在额外卡组时只能通过融合召唤（或接触融合）方式特殊召唤，其他特殊召唤方式不允许。
function s.splimit(e,se,sp,st)
	-- 若这张卡不在额外卡组则不受限制；若在额外卡组，则召唤方式必须为融合召唤（含接触融合）。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- ②效果的适用条件：自己场上存在里侧守备表示怪兽。
function s.atkcon(e)
	-- 检查这张卡的持有者（控制者）场上是否存在至少1只里侧守备表示怪兽。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
end
-- ③效果的发动条件：连锁中效果发动者（rp）为对方，即只有对方把效果发动时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 特召对象的过滤条件：卡组中1只「忍者」字段怪兽，且能以守备表示特殊召唤（符合召唤条件/苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 发动时检测：自己主要怪兽区有空位，且卡组中存在符合s.spfilter的「忍者」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足s.spfilter条件的「忍者」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 把‘从卡组特殊召唤1只怪兽’的操作信息登记到当前连锁，供其他卡（如星尘龙等）检查和时点触发。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理③效果：若场上仍有空位，则提示玩家从卡组选择1只「忍者」怪兽并特殊召唤到场上（守备表示）；若该怪兽被里侧守备表示特殊召唤，则向对方确认。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有主要怪兽区空格，若没有则效果处理不适用并终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 显示选择卡片的提示文字，要求玩家选择要特殊召唤的「忍者」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选出1张满足s.spfilter条件的「忍者」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的「忍者」怪兽以守备表示特殊召唤到自己场上，不检查召唤条件/苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
		if g:GetFirst():IsFacedown() then
			-- 将特殊召唤的里侧守备怪兽展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
