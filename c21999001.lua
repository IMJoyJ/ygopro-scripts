--光波双顎機
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在对方场上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：丢弃1张手卡才能发动。从手卡·卡组把1只「光波」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「光波」怪兽不能特殊召唤。
function c21999001.initial_effect(c)
	-- ①效果：从额外卡组特殊召唤的怪兽在对方场上存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c21999001.sprcon)
	c:RegisterEffect(e1)
	-- ②效果：丢弃1张手卡才能发动。从手卡·卡组把1只「光波」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「光波」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21999001,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21999001)
	e2:SetCost(c21999001.spcost)
	e2:SetTarget(c21999001.sptg)
	e2:SetOperation(c21999001.spop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则效果的条件：此卡在手牌时，若己方场上没有怪兽、对方场上有从额外卡组特殊召唤的怪兽且己方主要怪兽区有空位，则可作为无种类特殊召唤规则从手卡特殊召唤。
function c21999001.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方场上没有怪兽存在。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上存在至少1只从额外卡组特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
		-- 检查己方主要怪兽区有空位可以特殊召唤此卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 过滤可作为②效果代价丢弃的手牌：该手牌可以丢弃，且手牌·卡组中存在可特殊召唤的「光波」怪兽。
function c21999001.costfilter(c,e,tp)
	-- 判断候选手牌能否作为代价丢弃，并确认存在可特殊召唤的「光波」怪兽以供发动后的检索。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c21999001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 过滤手牌·卡组中可特殊召唤的「光波」怪兽：满足「光波」字段且能被当前效果特殊召唤。
function c21999001.spfilter(c,e,tp)
	return c:IsSetCard(0xe5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价判定：仅设置标签标记“已确认丢弃手牌”，实际丢弃在目标选择阶段进行。
function c21999001.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 目标选择阶段：先检查主怪兽区是否有空位；若已标记需要丢弃手牌，则选择并丢弃1张手牌作为代价；随后设置从手牌·卡组特殊召唤1只「光波」怪兽的操作信息。
function c21999001.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 发动时必须确保己方主要怪兽区有空位，否则无法特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if e:GetLabel()~=0 then
			e:SetLabel(0)
			-- 检查是否存在满足代价条件的可丢弃手牌（即能丢1手且手牌·卡组有「光波」怪兽可特召）。
			return Duel.IsExistingMatchingCard(c21999001.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		else
			-- 检查手牌·卡组中是否存在可特殊召唤的「光波」怪兽。
			return Duel.IsExistingMatchingCard(c21999001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	if e:GetLabel()~=0 then
		e:SetLabel(0)
		-- 向玩家提示：请选择要丢弃的手牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从手牌中选择1张满足条件的手牌作为代价。
		local g=Duel.SelectMatchingCard(tp,c21999001.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的手牌送入墓地，作为发动代价（丢弃）。
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	end
	-- 设置本次连锁的操作信息：效果处理时将进行1只怪兽的特殊召唤，来源为手牌和卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手牌·卡组特殊召唤1只「光波」怪兽，并给己方附加直到回合结束只能特殊召唤「光波」怪兽的自肃效果。
function c21999001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若己方主要怪兽区有空位，则进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌·卡组选择1只可特殊召唤的「光波」怪兽。
		local g=Duel.SelectMatchingCard(tp,c21999001.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「光波」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「光波」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21999001.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到己方玩家：直到回合结束时，己方不能特殊召唤非「光波」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定条件：被特殊召唤的怪兽不是「光波」怪兽时，禁止特殊召唤。
function c21999001.splimit(e,c)
	return not c:IsSetCard(0xe5)
end
