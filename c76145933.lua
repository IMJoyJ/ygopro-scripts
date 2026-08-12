--スプライト・ブルー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把「卫星闪灵·蓝色喷流灵」以外的1只「卫星闪灵」怪兽加入手卡。
function c76145933.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有2星或2阶的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,76145933+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c76145933.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤的场合才能发动。从卡组把「卫星闪灵·蓝色喷流灵」以外的1只「卫星闪灵」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,76145934)
	e2:SetTarget(c76145933.thtg)
	e2:SetOperation(c76145933.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的2星或2阶怪兽
function c76145933.filter(c)
	return (c:IsLevel(2) or c:IsRank(2)) and c:IsFaceup()
end
-- 特殊召唤规则的条件：自身控制者的怪兽区域有空位，且自己场上存在2星或2阶的怪兽
function c76145933.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张满足过滤条件的卡（表侧表示的2星或2阶怪兽）
		and Duel.IsExistingMatchingCard(c76145933.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中「卫星闪灵·蓝色喷流灵」以外的「卫星闪灵」怪兽
function c76145933.thfilter(c)
	return c:IsSetCard(0x180) and not c:IsCode(76145933) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的怪兽，并设置检索的操作信息
function c76145933.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76145933.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1只满足条件的怪兽加入手卡并给对方确认
function c76145933.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c76145933.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
