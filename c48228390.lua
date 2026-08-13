--黄鉄の愚騎士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「黄铁之愚骑士」以外的自己场上1只地·炎属性的战士族怪兽为对象才能发动。那只怪兽回到手卡，这张卡特殊召唤。那之后，在对方场上把1只「黄铁衍生物」（战士族·炎·4星·攻0/守2000）守备表示特殊召唤。
-- ②：自己·对方的战斗阶段才能发动。从手卡把1只战士族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册①、②两个效果——①在手卡·墓地可作为起动效果发动，取对象回手并特召自身及衍生物；②在场上于战斗阶段可作为诱发即时效果发动，从手卡特召战士族怪兽。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。 ①：这张卡在手卡·墓地存在的场合，以「黄铁之愚骑士」以外的自己场上1只地·炎属性的战士族怪兽为对象才能发动。那只怪兽回到手卡，这张卡特殊召唤。那之后，在对方场上把1只「黄铁衍生物」（战士族·炎·4星·攻0/守2000）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。 ②：自己·对方的战斗阶段才能发动。从手卡把1只战士族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的取对象过滤函数：选择自己场上表侧表示、卡名不为「黄铁之愚骑士」、地·炎属性、战士族、可被回手，且该卡离开后自己场上仍有空格子的怪兽。
function s.thfilter(c,tp)
	-- 判定目标怪兽需满足：表侧表示、不是本卡、战士族、地·炎属性、可加入手牌，并且其离开后自己场上仍有怪兽区空格。
	return c:IsFaceup() and not c:IsCode(id) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE) and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的target函数：先获取效果持有者；当进行连锁核对时验证对象位于自己场上且满足thfilter；当判定发动条件时，确认存在合法对象、本卡可被特殊召唤、可特招衍生物且对方场上有空格。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc,tp) end
	-- 发动条件：自己场上有1只满足thfilter的怪兽可作为对象，且这张卡本身能够被特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且当前玩家能在对方场上以表侧守备表示特殊召唤1只「黄铁衍生物」（战士族·炎·4星·攻0/守2000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,2000,4,RACE_WARRIOR,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,1-tp)
		-- 还要确保对方的主要怪兽区有空位。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 向操作者显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己场上选择1只满足thfilter的怪兽作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：该效果会将对象怪兽送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：该效果还会把这张卡自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若这张卡发动时在墓地，则额外设置操作信息：涉及墓地离场（用于王家长眠之谷等干扰）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ①效果处理：先将对象怪兽送回手牌，成功后将这张卡特殊召唤；若这两步均成功且仍能特招衍生物、对方场上有空位，则中断连锁在对方场上特招「黄铁衍生物」。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时仍然关联的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联且为怪兽，将其送回持有者手牌，并确认实际回手成功且现在位于手牌。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		-- 且这张卡自身仍与效果关联，并成功以表侧攻击表示特殊召唤。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 并且当前玩家仍能在对方场上特招「黄铁衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,2000,4,RACE_WARRIOR,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,1-tp)
		-- 且对方场上有空位时，才执行后续衍生物特招。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 中断当前效果处理，使衍生物的特殊召唤视为不同时进行的后续处理，以避免错过时点。
		Duel.BreakEffect()
		-- 创建1只「黄铁衍生物」token给当前玩家。
		local token=Duel.CreateToken(tp,id+o)
		-- 将衍生物以表侧守备表示特殊召唤到对方场上。
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件：当前为战斗阶段（从战斗阶段开始到战斗阶段结束）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处阶段并存入局部变量ph。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- ②效果的特召过滤条件：手牌中的战士族怪兽，且能够被通常效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的target函数：在发动时确认自己场上有空格且手牌存在符合条件的战士族怪兽，然后设置操作信息为从手卡特召。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动条件之一：自己场上必须存在可用的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手牌中存在至少1只满足spfilter的战士族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时会从手牌选择1只战士族怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若自己场上仍有空格，则从手牌选择1只战士族怪兽以表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用怪兽区，则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1只满足spfilter的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
