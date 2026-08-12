--ゴーティスの灯ペイシス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把「魊影之灯 佩西斯」以外的1只鱼族怪兽特殊召唤。
-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
-- ③：这张卡特殊召唤的对方回合的主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只鱼族同调怪兽的同调召唤。
local s,id,o=GetID()
-- 创建并注册三个效果，分别对应①②③效果的触发条件和处理方式
function s.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从手卡把「魊影之灯 佩西斯」以外的1只鱼族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 将此卡除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.sphtg)
	e1:SetOperation(s.sphop)
	c:RegisterEffect(e1)
	-- 当此卡被除外时触发的效果，用于记录除外回合数
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
-- 过滤函数，用于判断手牌中是否满足条件的鱼族怪兽（非本卡）
function s.filter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ①效果的发动时点处理函数，检查是否有足够的怪兽区和符合条件的手牌
function s.sphtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手牌中是否存在符合条件的鱼族怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，提示将要特殊召唤一张鱼族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的发动处理函数，选择并特殊召唤符合条件的鱼族怪兽
function s.sphop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一张符合条件的鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的鱼族怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 当此卡被除外时触发的效果处理函数，记录当前回合数并设置标记
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数
	local ct=Duel.GetTurnCount()
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- ②效果的发动条件判断函数，检查是否为下个回合且有标记
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为下个回合且有标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的目标设定函数，检查是否可以特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有可用怪兽区位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，提示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的发动处理函数，将此卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件判断函数，检查是否为对方回合且在主要阶段
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为对方回合且在主要阶段1或2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
-- 过滤函数，用于判断额外卡组中是否满足条件的鱼族同调怪兽
function s.sfilter(c,tc)
	return c:IsRace(RACE_FISH) and c:IsSynchroSummonable(tc)
end
-- ③效果的目标设定函数，检查是否有符合条件的鱼族同调怪兽
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在符合条件的鱼族同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置操作信息，提示将要进行鱼族同调召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果的发动处理函数，选择并进行鱼族同调召唤
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 从额外卡组中获取所有符合条件的鱼族同调怪兽
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sc,c)
	end
end
