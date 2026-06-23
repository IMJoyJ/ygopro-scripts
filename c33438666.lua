--ヴァンパイア・グリムゾン
-- 效果：
-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，可以作为代替而支付那些破坏的怪兽数量×1000基本分。
-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
function c33438666.initial_effect(c)
	-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，可以作为代替而支付那些破坏的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c33438666.reptg)
	e1:SetValue(c33438666.repval)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c33438666.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33438666,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c33438666.spcon)
	e3:SetTarget(c33438666.sptg)
	e3:SetOperation(c33438666.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足代替破坏条件的卡片：自己场上的怪兽、因战斗或对方效果破坏、非代替破坏。
function c33438666.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的目标处理：检查是否有满足条件的卡以及是否能支付基本分，并询问玩家是否发动。
function c33438666.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c33438666.repfilter,nil,tp)
	-- 检查是否存在至少1张满足条件的卡，且玩家有足够的基本分支付（每张1000）。
	if chk==0 then return ct>0 and Duel.CheckLPCost(tp,1000*ct) end
	-- 询问玩家是否支付基本分来代替破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 玩家支付破坏怪兽数量×1000的基本分。
		Duel.PayLPCost(tp,1000*ct)
		return true
	else return false end
end
-- 确定该代替破坏效果适用于哪些具体的卡片。
function c33438666.repval(e,c)
	return c33438666.repfilter(c,e:GetHandlerPlayer())
end
-- 在战斗破坏怪兽时，给自身添加一个持续到战斗阶段结束的标志。
function c33438666.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33438666,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 检查自身是否有战斗破坏过怪兽的标志，作为效果发动的条件。
function c33438666.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(33438666)~=0
end
-- 过滤满足特殊召唤条件的卡片：本回合被此卡战斗破坏、在墓地、可以特殊召唤。
function c33438666.spfilter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空格和墓地中是否存在可召唤的被破坏怪兽。
function c33438666.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有至少一个可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1张被此卡战斗破坏且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c33438666.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 获取墓地中所有被此卡战斗破坏且可特殊召唤的怪兽组。
	local g=Duel.GetMatchingGroup(c33438666.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 设置特殊召唤的操作信息，包含目标卡组和预计召唤数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的具体处理：计算可用空格，处理特殊限制，并从墓地特殊召唤选定的怪兽。
function c33438666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上可用的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取墓地中满足条件且不受王家长眠之谷影响的怪兽组。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33438666.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选定的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
