--雷盟－オルタネータ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上的怪兽的攻击力·守备力下降自己场上的雷族怪兽数量×300。
-- ②：从自己的手卡·场上（表侧表示）让这张卡以外的1张「雷盟」卡回到卡组才能发动。和回去的卡卡名不同的1只雷族怪兽从卡组加入手卡。
-- ③：把墓地的这张卡除外才能发动。从卡组把1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果注册
function s.initial_effect(c)
	-- 记录卡片关联卡号：37654623（天空城塞 库仑城寨）
	aux.AddCodeList(c,37654623)
	-- ①：对方场上的怪兽的攻击力·守备力下降自己场上的雷族怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置魔法卡发动条件：不能在伤害步骤伤害计算后发动
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力·守备力下降自己场上的雷族怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：从自己的手卡·场上（表侧表示）让这张卡以外的1张「雷盟」卡回到卡组才能发动。和回去的卡卡名不同的1只雷族怪兽从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索怪兽"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMING_END_PHASE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- ③：把墓地的这张卡除外才能发动。从卡组把1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"检索魔法"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	-- 设置效果③的发动Cost：将墓地的这张卡除外
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.thtg2)
	e5:SetOperation(s.thop2)
	c:RegisterEffect(e5)
end
-- 效果①的怪兽过滤函数，筛选自己场上表侧表示的雷族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 计算效果①攻击力/守备力下降的数值
function s.atkval(e,c)
	-- 计算己方场上雷族怪兽数量并乘以-300作为降低的数值
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*-300
end
-- 效果②的发动Cost过滤函数，筛选手卡·场上表侧表示的「雷盟」卡且其卡名不同于将要检索的雷族怪兽
function s.cfilter(c,tp)
	return c:IsSetCard(0x1df) and c:IsAbleToDeckAsCost() and c:IsFaceupEx()
		-- 检查卡组中是否存在与此卡卡名不同的雷族怪兽可以加入手卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 效果②的检索过滤函数，筛选卡组中与返回卡片卡名不同的雷族怪兽
function s.thfilter(c,code)
	return c:IsRace(RACE_THUNDER) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and not c:IsCode(code)
end
-- 效果②的Cost函数，处理将手卡·场上的「雷盟」卡回到卡组，并记录其卡名
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否拥有可以作为Cost返回卡组的「雷盟」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp) end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1张手卡或场上表侧表示的「雷盟」卡片
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c,tp)
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方展示被选为Cost的手卡
		Duel.ConfirmCards(1-tp,g)
	else
		-- 在场上给选中的卡片显示选为Cost的效果动画
		Duel.HintSelection(g)
	end
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选中的卡片送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果②的target函数，设置检索的连锁操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的雷族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,0) end
	if not e:IsCostChecked() then e:SetLabel(0) end
	-- 设置检索操作信息，表示从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的operation函数，处理从卡组将1只与Cost卡卡名不同的雷族怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件（与Cost卡不同名）的雷族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的检索过滤函数，筛选卡组中的「雷盟」魔法卡或「天空城塞 库仑城寨」
function s.thfilter2(c)
	return (c:IsCode(37654623) or c:IsSetCard(0x1df) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 效果③的target函数，检查卡组中是否存在可检索的卡，并设置检索操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的「雷盟」魔法卡或「天空城塞 库仑城寨」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息，表示从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的operation函数，处理从卡组将1张「雷盟」魔法卡或「天空城塞 库仑城寨」加入手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
