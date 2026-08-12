--K9－17号 イヅナ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
-- ②：对方把手卡·墓地的怪兽的效果发动的自己·对方回合的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ③：这张卡召唤·特殊召唤的场合才能发动。从卡组把「K9-17号 饭纲」以外的1张「K9」卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含不用解放召唤、手卡特殊召唤、召唤·特召成功时从卡组送墓效果，以及注册用于检测对方手卡·墓地怪兽效果发动的自定义计数器。
function s.initial_effect(c)
	-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤(K9-17号 饭纲)"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：对方把手卡·墓地的怪兽的效果发动的自己·对方回合的主要阶段才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤·特殊召唤的场合才能发动。从卡组把「K9-17号 饭纲」以外的1张「K9」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 注册自定义活动计数器，用于监测玩家发动连锁（效果）的行为，并通过过滤函数筛选出在手卡·墓地发动的怪兽效果。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 自定义计数器的过滤函数，用于筛选出在手卡或墓地发动的怪兽效果（若不是手卡或墓地发动的怪兽效果则返回true，不计入计数）。
function s.chainfilter(re,tp,cid)
	-- 获取当前连锁发动时的位置。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 不用解放召唤（妥协召唤）的条件判断函数。
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足通常召唤的基本规则条件（非召唤怪兽、等级5以上、怪兽区域有空位）。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方手卡是否存在2张以上的卡。
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_HAND,2,nil)
end
-- 手卡特殊召唤效果的发动条件判断函数。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方在本回合内是否发动过手卡·墓地的怪兽效果，且当前处于双方的主要阶段。
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0 and Duel.IsMainPhase()
end
-- 手卡特殊召唤效果的发动准备（Target）函数，检查自身是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡特殊召唤效果的执行（Operation）函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中「K9-17号 饭纲」以外的「K9」卡片且该卡能送去墓地的过滤函数。
function s.tgfilter(c)
	return c:IsSetCard(0x1cb) and not c:IsCode(id) and c:IsAbleToGrave()
end
-- 召唤·特召成功时送墓效果的发动准备（Target）函数。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「K9」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示此效果包含从卡组将1张卡送去墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 召唤·特召成功时送墓效果的执行（Operation）函数。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「K9」卡片。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
