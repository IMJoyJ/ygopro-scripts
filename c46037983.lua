--ゴーティスの灯ペイシス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把「魊影之灯 佩西斯」以外的1只鱼族怪兽特殊召唤。
-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
-- ③：这张卡特殊召唤的对方回合的主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只鱼族同调怪兽的同调召唤。
local s,id,o=GetID()
-- 定义卡片的初始化函数，依次注册①效果（除外自身从手卡特召其他鱼族）、被除外时的记录辅助效果、②效果（除外状态的准备阶段特召自身）、③效果（对方主要阶段进行鱼族同调召唤）。
function s.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从手卡把「魊影之灯 佩西斯」以外的1只鱼族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 设置①效果的发动代价为把场上的这张卡除外（aux.bfgcost）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.sphtg)
	e1:SetOperation(s.sphop)
	c:RegisterEffect(e1)
	-- 这张卡被除外的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(s.spreg)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：这张卡特殊召唤的对方回合的主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只鱼族同调怪兽的同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(s.syncon)
	e4:SetTarget(s.syntg)
	e4:SetOperation(s.synop)
	c:RegisterEffect(e4)
end
-- 定义①效果的筛选函数：满足鱼族、能够被特殊召唤、且卡名不是「魊影之灯 佩西斯」的怪兽。
function s.filter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ①效果的发动条件检查：自己场上有可用怪兽区域，且手牌中存在满足s.filter的鱼族怪兽。
function s.sphtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手牌中是否存在满足s.filter（鱼族、可特殊召唤、非本卡）的怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理信息为从手卡特殊召唤1只怪兽，用于连锁处理时告知系统。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若己方场上没有可用怪兽区则直接终止；否则提示玩家选择手牌中符合条件的鱼族怪兽，并将其特殊召唤。
function s.sphop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方场上没有可用怪兽区，则效果处理失败，直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足s.filter的鱼族怪兽（不含本卡）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 记录效果：当这张卡被除外时，记录当前回合数并给自身设置标记，为②效果判断“下个回合”做准备。
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数并保存，用于之后与准备阶段的回合数比较。
	local ct=Duel.GetTurnCount()
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- ②效果的发动条件：当前回合数不等于记录的被除外回合数（说明已到下个回合），且这张卡带有被除外时的标记。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合数不是被除外时的回合（即已到下个回合），且卡片带有被除外时设置的标记。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的目标检查：自己场上有可用怪兽区，且除外区的这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域，用于特殊召唤除外区的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果处理信息为特殊召唤这张卡，对象为除外区的此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果相关，则将其从除外区特殊召唤到己方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将除外状态的这张卡以表侧攻击表示特殊召唤到己方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果发动条件：当前为对方回合的主要阶段，且这张卡在本回合已被特殊召唤过。
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前为对方回合（当前回合玩家不是tp）的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
-- 筛选额外卡组中满足鱼族、且可以以这张卡为素材进行同调召唤的同调怪兽。
function s.sfilter(c,tc)
	return c:IsRace(RACE_FISH) and c:IsSynchroSummonable(tc)
end
-- ③效果的目标检查：额外卡组中存在可以以这张卡为素材进行同调召唤的鱼族同调怪兽；并设置操作信息为从额外卡组特殊召唤。
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在满足s.sfilter（鱼族且可作为同调素材）的同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置本次效果操作信息为从额外卡组特殊召唤1只同调怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果处理：若这张卡仍在场上且表侧表示，则从额外卡组选择一只符合条件的鱼族同调怪兽，以包含这张卡的己方场上怪兽为素材进行同调召唤。
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有满足s.sfilter的鱼族同调怪兽（可用本卡作为素材）。
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		-- 显示“请选择要特殊召唤的卡”的提示，用于选择要同调召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		-- 以这张卡为素材，将选择的鱼族同调怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sc,c)
	end
end
