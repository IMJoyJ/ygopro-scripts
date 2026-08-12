--神聖魔皇后セレーネ
-- 效果：
-- 包含魔法师族怪兽的怪兽2只以上
-- ①：这张卡连接召唤的场合发动。双方的场上·墓地的魔法卡数量的魔力指示物给这张卡放置。
-- ②：只要场上有「恩底弥翁」卡存在，对方怪兽不能选择这张卡作为攻击对象。
-- ③：1回合1次，自己·对方的主要阶段，把自己场上3个魔力指示物取除才能发动。从自己的手卡·墓地选1只魔法师族怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。
function c45819647.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2-3只怪兽作为连接素材，且其中至少包含1只魔法师族怪兽（由lcheck检查）
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
	-- 设定效果作用的对象为不免疫这个效果的对方怪兽，即不能免疫此效果的对方怪兽不能选择这张卡作为攻击对象
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
c45819647.mentioned_counter={
	[0x1]=true,
}
-- 连接素材的过滤函数：检查作为连接素材的怪兽组中是否至少存在1只魔法师族怪兽
function c45819647.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_SPELLCASTER)
end
-- 指示物数量的过滤函数：满足在墓地、表侧表示、作为装备卡装备中或在场地区域其中之一的魔法卡
function c45819647.ctfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() or c:GetEquipTarget() or c:IsLocation(LOCATION_FZONE)) and c:IsType(TYPE_SPELL)
end
-- 发动条件：这张卡是连接召唤出场的场合
function c45819647.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果处理：统计双方场上·墓地的魔法卡数量，这张卡表侧表示且仍与这个效果关联并且数量大于0时，给这张卡放置那个数量的魔力指示物
function c45819647.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计双方场上·墓地中满足条件的魔法卡的数量
	local ct=Duel.GetMatchingGroupCount(c45819647.ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 攻击对象限制的过滤函数：表侧表示的「恩底弥翁」卡（0x12a为恩底弥翁系列编号）
function c45819647.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12a)
end
-- 永续效果适用条件：自己或对方场上存在表侧表示的「恩底弥翁」卡
function c45819647.atcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的「恩底弥翁」卡
	return Duel.IsExistingMatchingCard(c45819647.atfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 发动条件：当前阶段是自己或对方的主要阶段1或主要阶段2
function c45819647.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 发动代价：检查自己场上是否有3个可因代价取除的魔力指示物，有则把自己场上3个魔力指示物取除
function c45819647.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以发动代价为由取除3个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 以发动代价为由把自己场上3个魔力指示物取除
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 特殊召唤对象的过滤函数：魔法师族且可以在作为这张卡所连接区的自己场上守备表示特殊召唤的怪兽
function c45819647.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 发动对象检查：取得这张卡所连接区中属于自己主要怪兽区的区域，检查自己主要怪兽区有空位且手卡·墓地存在能在该区域特殊召唤的魔法师族怪兽
function c45819647.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查自己主要怪兽区是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少1只能在该连接区域守备表示特殊召唤的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c45819647.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 设置操作信息：这个效果预计从自己的手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：这张卡仍与效果关联时，取得这张卡所连接区中自己的主要怪兽区域，若无可用区域则中断；否则从自己的手卡·墓地选1只魔法师族怪兽在该区域守备表示特殊召唤
function c45819647.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if zone==0 then return end
	-- 向玩家提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1只满足条件且不受王家长眠之谷影响的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45819647.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 把选择的怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
	end
end
