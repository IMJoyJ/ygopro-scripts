--ウォークライ・ウェント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的战士族·地属性怪兽和对方怪兽进行战斗的伤害计算时，支付800基本分才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升800。
-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
function c47504322.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己的战士族·地属性怪兽和对方怪兽进行战斗的伤害计算时，支付800基本分才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47504322,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47504322)
	e1:SetCondition(c47504322.atkcon)
	e1:SetCost(c47504322.atkcost)
	e1:SetOperation(c47504322.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47504322,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,47504323)
	e2:SetCondition(c47504322.spcon)
	e2:SetTarget(c47504322.sptg)
	e2:SetOperation(c47504322.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：获取自己操控的战斗怪兽和对方战斗怪兽，若自己怪兽存在且为战士族·地属性，则满足“自己的战士族·地属性怪兽和对方怪兽进行战斗”这一条件。
function c47504322.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的两只怪兽：a为自己（tp）操控的战斗怪兽，d为对方操控的战斗怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a:IsAttribute(ATTRIBUTE_EARTH) and a:IsRace(RACE_WARRIOR)
end
-- ①效果的发动代价：先检测玩家能否支付800基本分，若能则实际支付800基本分作为发动代价。
function c47504322.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）时，检查玩家是否足以支付800基本分，作为代价是否满足的判定。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际让玩家支付800基本分。
	Duel.PayLPCost(tp,800)
end
-- ①效果处理：给自己场上进行战斗的那只怪兽注册一个攻击力上升800的临时效果，使其攻击力直到回合结束时上升。
function c47504322.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己操控的正在进行战斗的怪兽，作为攻击力提升的对象。
	local tc=Duel.GetBattleMonster(tp)
	-- 那只进行战斗的自己怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
-- ②效果的发动条件：这张卡原本控制者为自己、从主要怪兽区域因对方发动的效果被送去墓地，即满足“这张卡被对方的效果从怪兽区域送去墓地的场合”。
function c47504322.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 特殊召唤的过滤条件：选择等级5以上、持有「战吼」字段、且能被玩家tp效果特殊召唤的怪兽。
function c47504322.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标：检查自己场上是否有可用的主要怪兽区域空位，并且手卡·卡组中存在至少1只符合条件的「战吼」怪兽，作为效果可发动的判定。
function c47504322.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时必须存在可用的主要怪兽区域空位，用于放置特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时要求手卡·卡组中存在至少1只满足spfilter条件的「战吼」怪兽，作为可发动的卡源。
		and Duel.IsExistingMatchingCard(c47504322.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的处理操作信息：效果类别为特殊召唤，预计从手卡·卡组特殊召唤1只怪兽，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：若仍有可用怪兽区域，则从手卡·卡组选择1只符合条件的「战吼」怪兽，以表侧表示特殊召唤到自己的主要怪兽区域。
function c47504322.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若场上没有可用主要怪兽区域，则特殊召唤处理不适用，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组中选择1只满足spfilter条件的「战吼」怪兽，选择结果存入组对象g。
	local g=Duel.SelectMatchingCard(tp,c47504322.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
