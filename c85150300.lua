--精霊の狩人
-- 效果：
-- ①：对方准备阶段1次，可以从以下效果选择1个发动。
-- ●从卡组把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ●对方可以把自己的魔法与陷阱区域1张怪兽卡在自身场上特殊召唤。那个场合，再让对方支付那个原本攻击力数值的基本分。
-- ②：对方场上有原本持有者是自己的效果怪兽特殊召唤的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从卡组把1只4星以下的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（对方准备阶段选择发动）和②效果（对方场上有原本持有者是自己的效果怪兽特召时送墓特召卡组怪兽）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方准备阶段1次，可以从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"选择1个效果发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ②：对方场上有原本持有者是自己的效果怪兽特殊召唤的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从卡组把1只4星以下的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定函数（必须在对方回合）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤卡组中可以作为永续魔法放置在魔法与陷阱区域的怪兽卡的条件。
function s.pfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤魔法与陷阱区域中可以被对方特殊召唤的怪兽卡，且对方LP必须大于等于其原本攻击力。
function s.sfilter(c,e,tp)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP,1-tp)
		-- 检查对方的当前LP是否大于等于该怪兽的原本攻击力，且该怪兽原本攻击力不为负数。
		and Duel.GetLP(1-tp)>=c:GetBaseAttack() and c:GetTextAttack()>=0
end
-- ①效果的发动准备与分支选择函数，根据场上和卡组状态判断可选的分支，并让玩家选择。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=0
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=1 end
	-- 检查自己场上是否有可用的魔法与陷阱区域空格（若此卡是从手卡发动，则需预留格子）。
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		-- 且自己卡组中存在至少1只满足放置条件的怪兽。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 检查对方场上是否有可用的怪兽区域空格。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 且自己魔法与陷阱区域存在至少1张满足特殊召唤条件的怪兽卡。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让发动效果的玩家从满足条件的选项中选择一个执行。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"放置怪兽"
			{b2,aux.Stringid(id,3),2})  --"对方特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
-- ①效果的分支效果处理函数，根据选择的分支执行对应的放置或特殊召唤并扣除LP。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 分支1处理：若自己魔法与陷阱区域没有空位，则不处理。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示自己选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从自己卡组选择1只满足条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽表侧表示移动到自己的魔法与陷阱区域。
			Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true)
			-- 当作永续魔法卡使用
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	elseif e:GetLabel()==2 then
		-- 分支2处理：若对方场上没有可用的怪兽区域空格，则不处理。
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
		-- 获取自己魔法与陷阱区域中所有满足特殊召唤条件的怪兽卡。
		local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_SZONE,0,nil,e,tp)
		::cancel::
		-- 若没有可特召的卡，或者对方选择不发动特殊召唤效果，则结束处理。
		if sg:GetCount()==0 or not Duel.SelectYesNo(1-tp,aux.Stringid(id,4)) then return false end  --"是否特殊召唤怪兽？"
		-- 提示对方选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local g=sg:CancelableSelect(1-tp,1,1,nil)
		if g==nil or g:GetCount()==0 then goto cancel end
		local tc=g:GetFirst()
		-- 若成功将该怪兽特殊召唤到对方场上。
		if tc and Duel.SpecialSummon(tc,0,1-tp,1-tp,false,false,POS_FACEUP)~=0 then
			-- 中断当前效果，使后续的支付基本分处理与特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 让对方支付该怪兽原本攻击力数值的基本分。
			Duel.SetLP(1-tp,Duel.GetLP(1-tp)-tc:GetBaseAttack())
		end
	end
end
-- 过滤被特殊召唤的怪兽：必须在对方场上、原本持有者是自己、且是效果怪兽。
function s.spfilter(c,tp)
	return c:IsControler(1-tp) and c:GetOwner()==tp and c:IsType(TYPE_EFFECT)
end
-- ②效果的发动条件判定函数（对方场上有原本持有者是自己的效果怪兽特殊召唤的场合）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp)
end
-- ②效果的发动代价处理函数（把魔法与陷阱区域表侧表示的这张卡送去墓地）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡作为发动代价送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的4星以下怪兽。
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备函数，检查自己场上是否有空位以及卡组中是否有可特召的怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己卡组中存在至少1只满足特殊召唤条件的4星以下怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表明此效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理函数，从卡组特殊召唤1只4星以下的怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示自己选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的4星以下怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
