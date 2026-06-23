--想定GUYS
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上没有怪兽存在的场合才能发动。从卡组把1只战士族·4星怪兽特殊召唤。
-- ●以自己场上1只战士族怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只战士族·地属性怪兽从自己的卡组·墓地特殊召唤。
local s,id,o=GetID()
-- 创建并注册一张发动时点为自由连锁的魔法卡效果，限制每回合只能发动一次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的战士族4星怪兽（可特殊召唤）
function s.sdfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于筛选满足条件的战士族场上怪兽（可作为对象）
function s.slfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 筛选场上战士族且正面表示的怪兽，并检查其等级是否大于0，同时确认在卡组或墓地存在满足等级条件的战士族地属性怪兽
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup() and lv>0 and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,lv,e,tp)
end
-- 过滤函数，用于筛选满足条件的战士族地属性怪兽（可特殊召唤）
function s.lvfilter(c,lv,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理函数，判断是否满足发动条件并选择发动选项
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断自己场上是否没有怪兽存在
	local b1 = not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 判断自己场上是否有空位且卡组中存在满足条件的战士族4星怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sdfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 判断自己场上是否有空位
	local b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否存在满足条件的战士族怪兽作为对象
		and Duel.IsExistingTarget(s.slfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动选项
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,0),0},  --"卡组把1只战士族·4星怪兽特殊召唤"
		{b2,aux.Stringid(id,1),1})  --"以自己场上1只战士族怪兽为对象，特殊召唤"
	e:SetLabel(op)
	if op==0 then
		-- 设置操作信息为从卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择场上1只战士族怪兽作为对象
		Duel.SelectTarget(tp,s.slfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		-- 设置操作信息为从卡组或墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- 效果的执行函数，根据选择的选项执行不同的特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local op = e:GetLabel()
	local g
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if op==0 then
		-- 从卡组中选择1只满足条件的战士族4星怪兽
		g = Duel.SelectMatchingCard(tp,s.sdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	else
		-- 获取当前连锁的效果对象
		local tc = Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsType(TYPE_MONSTER) then return end
		-- 从卡组或墓地中选择1只满足等级条件的战士族地属性怪兽
		g = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lvfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc:GetLevel(),e,tp)
	end
	if g and g:GetCount()>0 then
		-- 将符合条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
