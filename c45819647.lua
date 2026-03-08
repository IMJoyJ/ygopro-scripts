--神聖魔皇后セレーネ
-- 效果：
-- 包含魔法师族怪兽的怪兽2只以上
-- ①：这张卡连接召唤的场合发动。双方的场上·墓地的魔法卡数量的魔力指示物给这张卡放置。
-- ②：只要场上有「恩底弥翁」卡存在，对方怪兽不能选择这张卡作为攻击对象。
-- ③：1回合1次，自己·对方的主要阶段，把自己场上3个魔力指示物取除才能发动。从自己的手卡·墓地选1只魔法师族怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
function c45819647.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2到3个包含魔法师族怪兽的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,3,c45819647.lcheck)
	-- ①：这张卡连接召唤的场合发动。双方的场上·墓地的魔法卡数量的魔力指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45819647,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c45819647.ctcon)
	e1:SetOperation(c45819647.ctop)
	c:RegisterEffect(e1)
	-- ②：只要场上有「恩底弥翁」卡存在，对方怪兽不能选择这张卡作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(c45819647.atcon)
	-- 设置效果值为aux.imval1，使该效果生效时不会成为攻击对象
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己·对方的主要阶段，把自己场上3个魔力指示物取除才能发动。从自己的手卡·墓地选1只魔法师族怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45819647,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c45819647.spcon)
	e3:SetCost(c45819647.spcost)
	e3:SetTarget(c45819647.sptg)
	e3:SetOperation(c45819647.spop)
	c:RegisterEffect(e3)
end
-- 连接素材检查函数，确保连接素材中至少有一只魔法师族怪兽
function c45819647.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_SPELLCASTER)
end
-- 魔法卡过滤函数，用于统计双方场上和墓地的魔法卡数量
function c45819647.ctfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() or c:GetEquipTarget() or c:IsLocation(LOCATION_FZONE)) and c:IsType(TYPE_SPELL)
end
-- 效果发动条件函数，判断此卡是否为连接召唤成功
function c45819647.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果处理函数，将双方场上和墓地的魔法卡数量的魔力指示物放置到此卡上
function c45819647.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计双方场上和墓地的魔法卡数量
	local ct=Duel.GetMatchingGroupCount(c45819647.ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 攻击对象过滤函数，判断场上的「恩底弥翁」卡是否存在
function c45819647.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12a)
end
-- 效果发动条件函数，判断场上有「恩底弥翁」卡存在
function c45819647.atcon(e)
	-- 检查场上有「恩底弥翁」卡存在
	return Duel.IsExistingMatchingCard(c45819647.atfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤发动条件函数，判断当前阶段是否为主要阶段
function c45819647.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 特殊召唤消耗函数，检查是否可以移除3个魔力指示物作为代价
function c45819647.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除3个魔力指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 移除3个魔力指示物作为代价
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 特殊召唤目标过滤函数，筛选魔法师族怪兽
function c45819647.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 特殊召唤目标选择函数，检查是否有满足条件的魔法师族怪兽可特殊召唤
function c45819647.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否有魔法师族怪兽
		and Duel.IsExistingMatchingCard(c45819647.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 设置操作信息，确定特殊召唤的卡牌数量和来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤处理函数，选择并特殊召唤魔法师族怪兽
function c45819647.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if zone==0 then return end
	-- 提示玩家选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45819647.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的魔法师族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
	end
end
