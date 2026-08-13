--想定GUYS
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上没有怪兽存在的场合才能发动。从卡组把1只战士族·4星怪兽特殊召唤。
-- ●以自己场上1只战士族怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只战士族·地属性怪兽从自己的卡组·墓地特殊召唤。
local s,id,o=GetID()
-- 定义初始化函数：创建并注册这张卡的主要发动效果e1；该效果为特殊召唤相关的魔法卡发动效果，可在自由时点发动，每回合最多发动1次（使用“誓约”计数），并分别指定发动时选择目标函数与效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。
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
-- 定义选项1的检索/特殊召唤过滤条件：从卡组中选出种族为战士族、等级为4、且能被当前效果特殊召唤的怪兽。
function s.sdfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义选项2的取对象过滤条件：自己场上的表侧表示战士族怪兽，且其等级大于0，并且卡组·墓地中存在至少1只满足s.lvfilter（地属性·战士族·等级不高于它·可特殊召唤）的怪兽。
function s.slfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 返回该怪兽是否为表侧战士族且等级大于0，同时确认卡组·墓地中有至少1只等级不超过该怪兽等级且可特殊召唤的战士族·地属性怪兽。
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup() and lv>0 and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,lv,e,tp)
end
-- 定义特殊召唤对象的过滤条件：该怪兽是地属性、战士族，等级不超过指定数值lv，并且能被当前效果特殊召唤。
function s.lvfilter(c,lv,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标与选项处理函数：先计算两个选项是否可行（选项1：自己场上无怪兽且卡组有可特召的战士族4星；选项2：自己场上有可成为对象的表侧战士族怪兽），让玩家选择其中一个；将选择存入标签，若选择选项2则选择对象，并分别设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检测自己场上是否完全不存在怪兽（满足选项1“自己场上没有怪兽存在”的条件）。
	local b1 = not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认自己主要怪兽区有空位，并且卡组中存在至少1只满足s.sdfilter的战士族·4星可特殊召唤怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sdfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 检测自己主要怪兽区是否存在空闲区域（选项2发动也需要空位）。
	local b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己场上是否存在至少1只满足s.slfilter的战士族怪兽可作为效果对象。
		and Duel.IsExistingTarget(s.slfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 调用aux.SelectFromOptions让玩家从当前有效的两个选项中选择1个发动，并把所选选项的编号存入局部变量op。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,0),0},  --"卡组把1只战士族·4星怪兽特殊召唤"
		{b2,aux.Stringid(id,1),1})  --"以自己场上1只战士族怪兽为对象，特殊召唤"
	e:SetLabel(op)
	if op==0 then
		-- 设置操作信息：本次处理将进行特殊召唤，来源为自己卡组，数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		-- 向玩家发送“请选择效果的对象”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从自己场上选择1只满足s.slfilter的战士族怪兽作为效果对象，并将其登记为当前连锁的对象。
		Duel.SelectTarget(tp,s.slfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		-- 设置操作信息：本次处理将进行特殊召唤，来源为自己卡组或墓地，数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- 效果处理函数：根据发动时选择的选项，从卡组或卡组·墓地中选出符合条件的怪兽并特殊召唤到己方场上；若选项2的对象失效则效果不处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位；若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local op = e:GetLabel()
	local g
	-- 向玩家发送“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if op==0 then
		-- 从自己的卡组选择1只满足s.sdfilter（战士族·4星·可特殊召唤）的怪兽，作为特殊召唤的卡。
		g = Duel.SelectMatchingCard(tp,s.sdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	else
		-- 取出选项2在发动时选择并登记的对象怪兽。
		local tc = Duel.GetFirstTarget()
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsType(TYPE_MONSTER) then return end
		-- 从自己的卡组·墓地选择1只满足s.lvfilter（地属性·战士族·等级≤对象等级·可特殊召唤）且不受王家长眠之谷影响的怪兽。
		g = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lvfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc:GetLevel(),e,tp)
	end
	if g and g:GetCount()>0 then
		-- 将选择成功的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
