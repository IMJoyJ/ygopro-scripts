--紅蓮王 フレイム・クライム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有恶魔族调整存在的场合或者对方场上有特殊召唤的怪兽存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。给与对方为自己场上的炎属性怪兽种类×400伤害。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张通常陷阱卡送去墓地。
local s,id,o=GetID()
-- 定义卡片初始化函数，为『红莲王 炎罪』注册三个效果：①在主要阶段从手卡特殊召唤自身的诱发即时效果；②特殊召唤成功时给予对方伤害的诱发选发效果；③作为同调素材送去墓地时从卡组把1张通常陷阱送去墓地的诱发选发效果；三者各自有1回合1次的次数限制（分别使用不同计数代码）。
function s.initial_effect(c)
	-- ①：自己场上有恶魔族调整存在的场合或者对方场上有特殊召唤的怪兽存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。给与对方为自己场上的炎属性怪兽种类×400伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张通常陷阱卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 筛选条件：自己场上表侧表示且为恶魔族的调整怪兽，用于①效果的存在检查。
function s.scfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 筛选条件：对方场上表侧表示且通过特殊召唤方式出场的怪兽，用于①效果的存在检查。
function s.ocfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup()
end
-- ①效果的发动条件：必须处于主要阶段（自己或对方），且满足『自己场上有恶魔族调整』或『对方场上有特殊召唤怪兽』任一条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 阶段限制：当前阶段不是主要阶段1或主要阶段2时，效果不能发动。
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 检查自己场上是否存在至少1只表侧表示的恶魔族调整怪兽。
	return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只表侧表示的特殊召唤怪兽；与上一条件为或的关系。
		or Duel.IsExistingMatchingCard(s.ocfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- ①效果的发动目标判断：自己场上是否有可用怪兽区域，且手牌的这张卡是否满足可被特殊召唤的条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区空格数量大于0，否则无法从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次连锁将把这张卡自身作为特殊召唤对象（1张）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的实际处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：从手卡以表侧攻击表示（POS_FACEUP）特殊召唤这张卡。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选条件：表侧表示且属性为炎属性的怪兽，用于②效果的发动条件和伤害计算。
function s.afilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
-- ②效果的发动条件：自己场上存在至少1只表侧表示的炎属性怪兽。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（怪兽区或魔法陷阱区）是否存在至少1只表侧表示炎属性怪兽。
	return Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②效果的实际处理：统计自己场上表侧表示炎属性怪兽的卡名种类数，每种类×400伤害给予对方。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区所有表侧表示的炎属性怪兽，用于统计种类数。
	local g=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*400
	-- 给予对方玩家计算出的伤害（dam），伤害原因为效果。
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡作为同调素材被使用并已送去墓地（当前位于墓地且原因为同调召唤）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 筛选条件：类型为通常陷阱且能够被送去墓地的卡，用于从卡组选择送墓的陷阱卡。
function s.tgfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToGrave()
end
-- ③效果的目标判断：检查卡组是否存在符合条件的通常陷阱，并设置从卡组送墓的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中存在至少1张符合条件的通常陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地，操作区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果的实际处理：从卡组选择1张通常陷阱卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择提示，让玩家从卡组选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的通常陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
