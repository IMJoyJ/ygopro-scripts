--剣闘獣クラウディウス
-- 效果：
-- 「剑斗兽」怪兽×5
-- 让自己的场上·墓地的上记的卡回到卡组·额外卡组的场合才能从额外卡组特殊召唤。
-- ①：这张卡用上记的方法特殊召唤的场合才能发动。下次的自己战斗阶段可以进行2次。
-- ②：1回合1次，对方把怪兽的效果发动的场合，可以把发动回合的以下效果发动。
-- ●自己回合：从卡组把1只「剑斗兽」怪兽特殊召唤。
-- ●对方回合：从额外卡组把1只11星以下的「剑斗兽」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 卡牌初始化函数：注册融合召唤手续、接触融合手续、特殊召唤条件限制以及①“二连战”和②“对方发动怪兽效果时特殊召唤”两个效果。
function s.initial_effect(c)
	-- 注册融合召唤手续：以5只「剑斗兽」怪兽作为融合素材进行融合召唤（对应召唤素材“「剑斗兽」怪兽×5”）。
	aux.AddFusionProcFunRep(c,s.matfilter,5,true)
	c:EnableReviveLimit()
	-- 注册接触融合手续：选择自己场上·墓地的怪兽作为素材，将其送回卡组·额外卡组作为特殊召唤代价，并标记本次特殊召唤为自身效果（SUMMON_VALUE_SELF），用于后续判定是否满足①条件。
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_MZONE+LOCATION_GRAVE,0,aux.ContactFusionSendToDeck(c)):SetValue(SUMMON_VALUE_SELF)
	-- 才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：这张卡用上记的方法特殊召唤的场合才能发动。下次的自己战斗阶段可以进行2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次战阶"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.btcon)
	e1:SetOperation(s.btop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽的效果发动的场合，可以把发动回合的以下效果发动。●自己回合：从卡组把1只「剑斗兽」怪兽特殊召唤。●对方回合：从额外卡组把1只11星以下的「剑斗兽」怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件限制：仅允许此卡从额外卡组特殊召唤，阻止从墓地、除外等区域特殊召唤。
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 融合素材判断：素材怪兽必须是「剑斗兽」系列怪兽（满足作为融合素材的判定）。
function s.matfilter(c)
	return c:IsFusionSetCard(0x1019) and c:IsFusionType(TYPE_MONSTER)
end
-- 接触融合素材过滤：选择自己场上·墓地的怪兽，且该怪兽可以作为融合素材被送回卡组·额外卡组。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- ①效果的发动条件：这张卡是通过上述融合/接触融合方式特殊召唤成功（召唤类型为特殊召唤且带SUMMON_VALUE_SELF标记）的场合才能发动。
function s.btcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ①效果处理：为玩家赋予“下一次自己的战斗阶段可以进行2次”的效果；如果发动时自己正处于战斗阶段，则跳过当前战斗阶段，从下一个自己的战斗阶段开始适用。
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡用上记的方法特殊召唤的场合才能发动。下次的自己战斗阶段可以进行2次。②：1回合1次，对方把怪兽的效果发动的场合，可以把发动回合的以下效果发动。●自己回合：从卡组把1只「剑斗兽」怪兽特殊召唤。●对方回合：从额外卡组把1只11星以下的「剑斗兽」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前是否为己方回合的战斗阶段，若是则通过记录回合数跳过当前战斗阶段，确保效果作用于“下次”战斗阶段。
	if Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 将当前回合数记录到效果标签中，供后续条件比较使用。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	end
	-- 把二连战效果注册给己方玩家，使其在下次战斗阶段适用。
	Duel.RegisterEffect(e1,tp)
end
-- 二连战效果的持续条件：当前回合数不等于效果标签记录的回合数，即已经度过发动时的那个战斗阶段后才生效。
function s.bpcon(e)
	-- 返回当前回合数是否已经变化（与发动时不同），用于跳过当前战斗阶段。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- ②效果的发动条件：对方玩家发动了怪兽效果（连锁来源控制者为自己对手），且该效果为怪兽效果，满足时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 特殊召唤对象的过滤条件：必须是「剑斗兽」怪兽；若为对方回合，则追加要求11星以下、可无视召唤条件特殊召唤且额外区域有空位；若为己方回合，则要求可从卡组通常特殊召唤且主怪兽区有空位。
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1019) or not c:IsType(TYPE_MONSTER) then return false end
	-- 判断当前是否为对方回合，以此选择特殊召唤的来源：对方回合选额外卡组，自己回合选卡组。
	if Duel.GetTurnPlayer()==1-tp then
		-- 对方回合分支：对象必须是11星以下的「剑斗兽」怪兽，可以无视召唤条件特殊召唤，并确保有从额外卡组出场的空格。
		return c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 己方回合分支：对象可以从卡组按通常规则特殊召唤，并确保自己的主要怪兽区域有空位。
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- ②效果发动时的合法性检查与信息登记：根据当前回合决定检索区域（卡组或额外卡组），确认存在可特殊召唤的「剑斗兽」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK
	-- 根据当前回合设置检索位置：对方回合从额外卡组，自己回合从卡组。
	if Duel.GetTurnPlayer()==1-tp then loc=LOCATION_EXTRA end
	-- 发动时检查：对应区域内必须存在至少1只满足条件的「剑斗兽」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	-- 设置操作信息：本效果执行特殊召唤，预定从对应区域特殊召唤1只怪物（具体对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
-- ②效果处理：按当前回合选择从卡组或额外卡组特殊召唤1只符合条件的「剑斗兽」怪兽；从额外卡组时直接无视召唤条件特召，从卡组时按分步特召方式处理，并为从卡组特召的怪兽登记一个重置标记。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_DECK
	-- 根据当前回合选择特殊召唤来源：对方回合从额外卡组，自己回合从卡组。
	if Duel.GetTurnPlayer()==1-tp then loc=LOCATION_EXTRA end
	-- 弹出“请选择要特殊召唤的卡”的提示，将选择消息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从对应区域选择1张符合条件的「剑斗兽」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if loc==LOCATION_EXTRA then
			-- 从额外卡组特殊召唤时，将该怪兽以表侧表示特殊召唤到己方场上（无视召唤条件、不检查召唤限制）。
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		else
			-- 从卡组特殊召唤时，先使用分步特殊召唤第一步，将该怪兽以表侧表示加入特殊召唤处理。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
			-- 完成分步特殊召唤，正式特殊召唤成功并触发后续时点。
			Duel.SpecialSummonComplete()
		end
	end
end
