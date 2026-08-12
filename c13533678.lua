--スプライト・ジェット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「卫星闪灵」魔法·陷阱卡加入手卡。
function c13533678.initial_effect(c)
	-- ①：自己场上有2星或2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13533678+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c13533678.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「卫星闪灵」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,13533679)
	e2:SetTarget(c13533678.thtg)
	e2:SetOperation(c13533678.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在2星或2阶的怪兽。
function c13533678.filter(c)
	return (c:IsLevel(2) or c:IsRank(2)) and c:IsFaceup()
end
-- 特殊召唤的条件判断函数，检查是否满足特殊召唤条件。
function c13533678.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家的怪兽区域是否有空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1只2星或2阶的怪兽。
		and Duel.IsExistingMatchingCard(c13533678.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选卡组中「卫星闪灵」魔法·陷阱卡。
function c13533678.thfilter(c)
	return c:IsSetCard(0x180) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果的发动目标函数，用于确定效果处理时的目标。
function c13533678.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「卫星闪灵」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c13533678.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，指定将1张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的发动处理函数，用于执行效果的处理流程。
function c13533678.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张满足条件的「卫星闪灵」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c13533678.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被选中的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
