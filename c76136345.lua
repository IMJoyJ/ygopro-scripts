--転回操車
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有机械族·地属性·10星怪兽召唤·特殊召唤的场合才能发动。从卡组把1只攻击力1800以上的机械族·地属性·4星怪兽特殊召唤。这个效果特殊召唤的怪兽的等级变成10星。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
-- ②：把自己1张手卡送去墓地才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
function c76136345.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有机械族·地属性·10星怪兽召唤·特殊召唤的场合才能发动。从卡组把1只攻击力1800以上的机械族·地属性·4星怪兽特殊召唤。这个效果特殊召唤的怪兽的等级变成10星。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76136345,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,76136345)
	e2:SetCondition(c76136345.spcon)
	e2:SetTarget(c76136345.sptg)
	e2:SetOperation(c76136345.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：把自己1张手卡送去墓地才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(76136345,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,76136345)
	e4:SetCost(c76136345.thcost)
	e4:SetTarget(c76136345.thtg)
	e4:SetOperation(c76136345.thop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的机械族·地属性·10星怪兽
function c76136345.cfilter(c,tp)
	return c:IsFaceup() and c:IsLevel(10) and c:IsControler(tp) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 检查召唤·特殊召唤成功的怪兽中是否存在满足条件的怪兽
function c76136345.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76136345.cfilter,1,nil,tp)
end
-- 过滤卡组中攻击力1800以上的机械族·地属性·4星怪兽
function c76136345.filter(c,e,tp)
	return c:IsLevel(4) and c:IsAttackAbove(1800) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备，检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c76136345.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c76136345.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理，从卡组特殊召唤怪兽并将其等级变成10星，之后适用对方受到的战斗伤害变成0的效果
function c76136345.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c76136345.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 尝试将选中的怪兽以表侧表示特殊召唤
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的等级变成10星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(10)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。/ ②：把自己1张手卡送去墓地才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“对方受到的战斗伤害变成0”的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果②的发动代价，将1张手卡送去墓地
function c76136345.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择1张手卡送去墓地作为发动代价
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤卡组中机械族·地属性·10星怪兽
function c76136345.thfilter(c)
	return c:IsLevel(10) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果②的发动准备，检查卡组中是否存在可检索的怪兽，并设置检索的操作信息
function c76136345.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76136345.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息，表示从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理，从卡组将1只机械族·地属性·10星怪兽加入手卡
function c76136345.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c76136345.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
