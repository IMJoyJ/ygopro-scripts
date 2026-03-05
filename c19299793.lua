--紅蓮王 フレイム・クライム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有恶魔族调整存在的场合或者对方场上有特殊召唤的怪兽存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。给与对方为自己场上的炎属性怪兽种类×400伤害。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张通常陷阱卡送去墓地。
local s,id,o=GetID()
-- 初始化效果函数，注册三个诱发效果：①特殊召唤、②特殊召唤后造成伤害、③作为同调素材送去墓地时的效果
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
-- 过滤函数，用于判断自己场上是否存在恶魔族调整
function s.scfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 过滤函数，用于判断对方场上是否存在特殊召唤的怪兽
function s.ocfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup()
end
-- 效果发动条件判断函数，判断是否在主要阶段且满足①条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段1或主要阶段2
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 判断自己场上是否存在恶魔族调整
	return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在特殊召唤的怪兽
		or Duel.IsExistingMatchingCard(s.ocfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤效果的目标设定函数，检查是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将此卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将此卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断自己场上是否存在炎属性怪兽
function s.afilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
-- 伤害效果的发动条件判断函数，判断自己场上是否存在炎属性怪兽
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在炎属性怪兽
	return Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 伤害效果的处理函数，计算并造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有炎属性怪兽的集合
	local g=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*400
	-- 对对方造成伤害，伤害值为场上炎属性怪兽数量乘以400
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
-- 作为同调素材送去墓地效果的发动条件判断函数，判断是否因同调而送去墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于判断卡组中是否存在通常陷阱卡
function s.tgfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToGrave()
end
-- 送去墓地效果的目标设定函数，检查是否可以将陷阱卡送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要将一张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送去墓地效果的处理函数，选择并送去墓地一张陷阱卡
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
