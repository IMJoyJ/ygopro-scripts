--K9－ØØ号 ルプス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把手卡·墓地的怪兽的效果发动的自己·对方回合的主要阶段才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：对方回合才能发动。用包含这张卡的自己场上的怪兽为素材进行超量召唤。
-- ③：持有这张卡作为素材中的超量怪兽得到以下效果。
-- ●对方不能把这张卡作为效果的对象。
local s,id,o=GetID()
-- 注册卡片效果：①手卡·墓地特殊召唤，②对方回合用场上怪兽超量召唤，③作为超量素材赋予抗性，以及注册用于检测对方手卡·墓地怪兽效果发动的自定义计数器。
function s.initial_effect(c)
	-- ①：对方把手卡·墓地的怪兽的效果发动的自己·对方回合的主要阶段才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合才能发动。用包含这张卡的自己场上的怪兽为素材进行超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.xyzcon)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	-- ③：持有这张卡作为素材中的超量怪兽得到以下效果。●对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为对方卡的效果的对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，用于记录玩家在连锁中发动特定效果的次数。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数：检测发动的效果是否为手卡或墓地的怪兽效果。
function s.chainfilter(re,tp,cid)
	-- 获取触发该连锁的效果的发动位置。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 效果①的发动条件：对方在手卡·墓地发动过怪兽效果的自己或对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方本回合是否发动过手卡·墓地的怪兽效果，且当前为主要阶段。
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0 and Duel.IsMainPhase()
end
-- 效果①的发动准备：检查自己场上是否有空位以及自身是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤，并添加离场时除外的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与连锁相关、是否受王家长眠之谷影响，并尝试将自身表侧表示特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：对方回合才能发动。用包含这张卡的自己场上的怪兽为素材进行超量召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 效果②的发动条件：对方回合。
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 额外卡组超量怪兽的过滤函数：检查自己场上的怪兽中是否存在包含自身且满足超量召唤条件的素材组合。
function s.exgfilter(c,mg,mc)
	return mg:CheckSubGroup(s.exgselect,1,#mg,c,mc)
end
-- 超量素材组合的过滤函数：检查素材组中是否包含自身，且目标超量怪兽可以使用该素材组进行超量召唤。
function s.exgselect(g,exc,mc)
	return g:IsContains(mc) and exc:IsXyzSummonable(g,#g,#g)
end
-- 效果②的发动准备：获取自己场上表侧表示的怪兽，检查额外卡组是否存在可超量召唤的怪兽，并设置特殊召唤的操作信息。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示的怪兽作为潜在的超量素材。
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 检查额外卡组中是否存在可以用包含自身在内的场上怪兽为素材进行超量召唤的怪兽。
	if chk==0 then return Duel.GetMatchingGroupCount(s.exgfilter,tp,LOCATION_EXTRA,0,nil,mg,c)>0 end
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：选择要超量召唤的额外卡组怪兽，并选择包含自身在内的场上怪兽作为素材进行超量召唤。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取自己场上所有表侧表示的怪兽作为超量素材候选。
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 筛选出额外卡组中可以使用包含自身在内的场上怪兽进行超量召唤的怪兽组。
	local exg=Duel.GetMatchingGroup(s.exgfilter,tp,LOCATION_EXTRA,0,nil,mg,c)
	if #exg==0 then return end
	-- 提示玩家选择要特殊召唤（超量召唤）的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sc=exg:Select(tp,1,1,nil):GetFirst()
	-- 提示玩家选择要作为超量素材的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local msg=mg:SelectSubGroup(tp,s.exgselect,false,1,#mg,sc,c)
	-- 使用选定的素材对选定的怪兽进行超量召唤。
	Duel.XyzSummon(tp,sc,msg,#msg,#msg)
end
