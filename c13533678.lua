--スプライト・ジェット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「卫星闪灵」魔法·陷阱卡加入手卡。
function c13533678.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有2星或2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13533678+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c13533678.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤的场合才能发动。从卡组把1张「卫星闪灵」魔法·陷阱卡加入手卡。
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
-- 筛选表侧表示且等级为2或阶级为2的怪兽，用于判断场上是否存在满足『2星或2阶的怪兽』条件的怪兽。
function c13533678.filter(c)
	return (c:IsLevel(2) or c:IsRank(2)) and c:IsFaceup()
end
-- 特殊召唤规则的条件函数：若c为空则视为条件成立；否则要求我方主要怪兽区有空位，且我方场上有表侧表示的2星或2阶怪兽存在。
function c13533678.spcon(e,c)
	if c==nil then return true end
	-- 检查该怪兽的控制者（我方）主要怪兽区是否有可用的空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查我方场上主要怪兽区是否存在至少1张满足c13533678.filter的怪兽（即表侧表示的2星或2阶怪兽）。
		and Duel.IsExistingMatchingCard(c13533678.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检索过滤器：筛选卡组中卡名带有「卫星闪灵」字段的魔法·陷阱卡，且该卡能够加入手卡。
function c13533678.thfilter(c)
	return c:IsSetCard(0x180) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动目标函数：在发动时检查卡组中是否存在符合检索条件的卡，并设置本次处理将1张卡加入手卡的操作信息。
function c13533678.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：当chk==0时，确认卡组中有至少1张「卫星闪灵」魔法·陷阱卡可以加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c13533678.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组加入持有者的手卡，目标玩家为tp，对象位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组挑选1张符合条件的「卫星闪灵」魔法·陷阱卡加入手卡，并展示给对方。
function c13533678.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，要求其选择要加入手牌的卡（提示文字为『请选择要加入手牌的卡』）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足thfilter条件的卡，作为不取对象的检索处理。
	local g=Duel.SelectMatchingCard(tp,c13533678.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去其持有者的手卡（即加入手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
