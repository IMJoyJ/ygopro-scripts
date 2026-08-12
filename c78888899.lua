--重騎兵エメトⅥ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，对方回合，以「重骑兵 真理6」以外的自己场上1只「百夫长骑士」怪兽为对象才能发动。那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置，这张卡特殊召唤。这个回合，自己不能把「重骑兵 真理6」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①和②两个效果的定义。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，对方回合，以「重骑兵 真理6」以外的自己场上1只「百夫长骑士」怪兽为对象才能发动。那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置，这张卡特殊召唤。这个回合，自己不能把「重骑兵 真理6」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数（只能在对方回合发动）。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤满足作为效果①对象的「百夫长骑士」怪兽的条件。
function s.filter(c,tp)
	-- 判定卡片是否为表侧表示的「百夫长骑士」怪兽（「重骑兵 真理6」除外），且该卡离开场上后能空出怪兽区域。
	return c:IsFaceup() and c:IsSetCard(0x1a2) and not c:IsCode(id) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动准备与合法性检测函数（Target）。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 判定自己魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以作为对象的怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理函数（将对象怪兽放置到魔陷区，并特殊召唤自身，最后施加特招限制）。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定魔陷区是否有空位，且对象怪兽是否仍适用此效果。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsRelateToEffect(e)
		-- 将对象怪兽表侧表示移动到自己的魔法与陷阱区域。
		and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) then
			-- 将这张卡特殊召唤。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把「重骑兵 真理6」特殊召唤。②：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤同名卡的玩家限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤「重骑兵 真理6」的过滤函数。
function s.splimit(e,c)
	return c:IsCode(id)
end
-- 效果②的发动条件判定函数（在魔陷区作为永续陷阱卡存在，且在双方的主要阶段）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 效果②的发动准备与合法性检测函数（Target）。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定玩家是否可以特殊召唤该怪兽（检测召唤限制等）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT,2000,3000,8,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数（特殊召唤自身）。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
