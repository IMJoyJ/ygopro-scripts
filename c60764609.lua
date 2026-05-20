--魔を刻むデモンスミス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「刻魔」魔法·陷阱卡加入手卡。
-- ②：以自己场上1张「刻魔」装备卡和场上1只怪兽为对象才能发动。那些卡送去墓地。
-- ③：这张卡在墓地存在的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「刻魔」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张「刻魔」装备卡和场上1只怪兽为对象才能发动。那些卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的启动代价（Cost）判定与执行函数。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡从手卡丢弃送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「刻魔」魔法·陷阱卡且能加入手卡的过滤条件函数。
function s.filter(c)
	return c:IsSetCard(0x1b0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动条件判定与效果分类、操作信息设置函数（Target）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在至少1张满足条件的「刻魔」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「刻魔」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤自己场上表侧表示的「刻魔」装备卡且能送去墓地的过滤条件函数。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b0) and c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- 效果②的对象选择与发动判定函数（Target）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己魔法与陷阱区是否存在至少1张满足条件的「刻魔」装备卡。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_SZONE,0,1,nil)
		-- 判定场上是否存在至少1只可以送去墓地的怪兽。
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡（第一张，即「刻魔」装备卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张「刻魔」装备卡作为效果对象。
	local g1=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要送去墓地的卡（第二张，即场上的怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁信息，表示该效果的处理为将选中的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,g1:GetCount(),0,0)
end
-- 效果②的效果处理（Operation）函数。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的所有卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍存在于场上的对象卡送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
-- 过滤自己墓地中除自身以外的恶魔族·光属性怪兽且能返回卡组或额外卡组的过滤条件函数。
function s.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
-- 效果③的启动代价（Cost）判定与执行函数。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定自己墓地中是否存在至少1只除自身以外的恶魔族·光属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只除自身以外的恶魔族·光属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 给选中的卡片显示被选择的动画效果。
	Duel.HintSelection(g)
	-- 作为发动代价，将选择的怪兽送回持有者的卡组或额外卡组。
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
-- 效果③的发动条件判定与效果分类、操作信息设置函数（Target）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果的处理为将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理（Operation）函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
