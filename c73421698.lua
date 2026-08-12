--ゴーティスの妖精シフ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把墓地的这张卡除外，以自己场上1只鱼族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
-- ③：这张卡特殊召唤的对方回合的主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只鱼族同调怪兽的同调召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含：①墓地起动增加鱼族怪兽攻击力；②除外时记录回合数；③除外下个回合准备阶段特殊召唤；④对方回合主要阶段进行同调召唤。
function s.initial_effect(c)
	-- ①：把墓地的这张卡除外，以自己场上1只鱼族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 发动代价：将墓地的这张卡除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.atkuptg)
	e1:SetOperation(s.atkupop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。（此效果为记录除外时点的辅助效果）
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
-- 过滤条件：自己场上表侧表示的鱼族怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 效果①的发动准备与目标选择：检查场上是否存在表侧表示的鱼族怪兽，并将其设为效果对象。
function s.atkuptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否存在至少1只可以作为对象的表侧表示鱼族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的鱼族怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：使作为对象的怪兽攻击力直到回合结束时上升500。
function s.atkupop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 辅助效果②的注册函数：在这张卡被除外时，记录当前的回合数，并给自身注册一个持续2个回合的Flag，用于判定“下个回合”。
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合数。
	local ct=Duel.GetTurnCount()
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 效果②的发动条件：当前回合不是被除外的那一回合（即下个回合或更晚），且卡片带有被除外时注册的Flag。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合数不等于除外时的回合数（确保是下个回合），且Flag依然存在（确保在2个回合的有效时效内）。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- 效果②的发动准备：检查怪兽区域是否有空位，以及自身是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将除外状态的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果③的发动条件：对方回合的主要阶段，且这张卡是在本回合特殊召唤的。
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
-- 过滤条件：额外卡组中可以使用指定怪兽（本卡）作为素材进行同调召唤的鱼族同调怪兽。
function s.sfilter(c,tc)
	return c:IsRace(RACE_FISH) and c:IsSynchroSummonable(tc)
end
-- 效果③的发动准备：检查额外卡组中是否存在可以同调召唤的鱼族同调怪兽。
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只可以使用这张卡作为素材进行同调召唤的鱼族同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：选择额外卡组中1只合法的鱼族同调怪兽，以包含这张卡的自己场上怪兽为素材进行同调召唤。
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以使用这张卡作为素材进行同调召唤的鱼族同调怪兽。
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		-- 以这张卡作为同调素材，对选定的怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sc,c)
	end
end
