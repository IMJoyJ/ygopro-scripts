--ウォークライ・ウェント
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的战士族·地属性怪兽和对方怪兽进行战斗的伤害计算时，支付800基本分才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升800。
-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
function c47504322.initial_effect(c)
	-- ①：自己的战士族·地属性怪兽和对方怪兽进行战斗的伤害计算时，支付800基本分才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升800。
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
	-- ②：这张卡被对方的效果从怪兽区域送去墓地的场合才能发动。从手卡·卡组把1只5星以上的「战吼」怪兽特殊召唤。
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
-- 判断是否满足效果①的发动条件，即自己场上是否有战士族且属性为地的怪兽正在战斗中
function c47504322.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己怪兽和对方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a:IsAttribute(ATTRIBUTE_EARTH) and a:IsRace(RACE_WARRIOR)
end
-- 支付800基本分作为效果①的费用
function c47504322.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 使进行战斗的自己怪兽攻击力上升800点
function c47504322.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己怪兽
	local tc=Duel.GetBattleMonster(tp)
	-- 给该怪兽添加攻击力增加800的效果，持续到回合结束
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
-- 判断是否满足效果②的发动条件，即此卡是否被对方效果送入墓地且在怪兽区域
function c47504322.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 过滤函数：筛选5星以上且为「战吼」卡组的怪兽
function c47504322.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果②的发动条件，检查场上是否有空位以及手牌/卡组中是否存在符合条件的怪兽
function c47504322.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c47504322.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 执行效果②的处理流程，选择并特殊召唤符合条件的怪兽
function c47504322.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位以进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c47504322.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
