--雪の天気模様
-- 效果：
-- ①：「雪之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●把这张卡除外才能发动。从卡组把1张「天气」卡加入手卡。这个效果的发动后，直到回合结束时自己不能用抽卡以外的方法从卡组把卡加入手卡。这个效果在对方回合也能发动。
function c80577258.initial_effect(c)
	c:SetUniqueOnField(1,0,80577258)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●把这张卡除外才能发动。从卡组把1张「天气」卡加入手卡。这个效果的发动后，直到回合结束时自己不能用抽卡以外的方法从卡组把卡加入手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80577258,0))  --"从卡组把1张「天气」卡加入手卡（雪之天气模样）"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	-- 将自身除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c80577258.thtg)
	e2:SetOperation(c80577258.thop)
	-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c80577258.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤得到效果的怪兽：自己主要怪兽区域内、与此卡相同纵列及相邻纵列的「天气」效果怪兽
function c80577258.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 过滤卡组中可加入手牌的「天气」卡
function c80577258.thfilter(c)
	return c:IsSetCard(0x109) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的「天气」卡，向对方玩家提示发动效果，并设置将卡加入手牌的操作信息
function c80577258.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的「天气」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80577258.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置在连锁处理时将1张卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 检索效果的处理：从卡组选择1张「天气」卡加入手牌并给对方确认，之后适用“直到回合结束时自己不能用抽卡以外的方法从卡组把卡加入手卡”的限制
function c80577258.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「天气」卡
	local g=Duel.SelectMatchingCard(tp,c80577258.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 限制效果的影响对象为卡组中的卡（即不能将卡组中的卡加入手牌）
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该限制效果，使其在当前回合内生效
	Duel.RegisterEffect(e1,tp)
end
