--黄鉄の愚騎士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「黄铁之愚骑士」以外的自己场上1只地·炎属性的战士族怪兽为对象才能发动。那只怪兽回到手卡，这张卡特殊召唤。那之后，在对方场上把1只「黄铁衍生物」（战士族·炎·4星·攻0/守2000）守备表示特殊召唤。
-- ②：自己·对方的战斗阶段才能发动。从手卡把1只战士族怪兽特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以「黄铁之愚骑士」以外的自己场上1只地·炎属性的战士族怪兽为对象才能发动。那只怪兽回到手卡，这张卡特殊召唤。那之后，在对方场上把1只「黄铁衍生物」（战士族·炎·4星·攻0/守2000）守备表示特殊召唤。
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
	-- ②：自己·对方的战斗阶段才能发动。从手卡把1只战士族怪兽特殊召唤。
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
-- 定义用于筛选目标怪兽的过滤函数
function s.thfilter(c,tp)
	-- 筛选条件：场上正面表示、不是黄铁之愚骑士、战士族、地·炎属性、能回到手牌、且自己场上有空位
	return c:IsFaceup() and not c:IsCode(id) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE) and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的发动时点处理函数，检查是否满足发动条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc,tp) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,2000,4,RACE_WARRIOR,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,1-tp)
		-- 检查对方场上是否有空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息：此卡离开墓地（若在墓地）
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ①效果的处理函数，执行效果内容
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且能送回手牌
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		-- 判断此卡是否能特殊召唤
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,2000,4,RACE_WARRIOR,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,1-tp)
		-- 检查对方场上是否有空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 中断当前效果处理，避免错时点
		Duel.BreakEffect()
		-- 创建黄铁衍生物
		local token=Duel.CreateToken(tp,id+o)
		-- 将衍生物特殊召唤到对方场上
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件函数，判断是否在战斗阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 定义用于筛选手牌战士族怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点处理函数，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在符合条件的战士族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理函数，执行效果内容
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的手牌怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
