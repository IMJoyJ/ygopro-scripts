--タウセネト・アジャト
-- 效果：
-- 「塞尼特」卡降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把「塔乌塞尼特·阿贾特」以外的1张「塞尼特」卡送去墓地。
-- ②：有装备卡装备的这张卡不会被效果破坏。
-- ③：自己·对方回合，把自己场上最多3张表侧表示的通常怪兽卡送去墓地，以那个数量的对方场上的卡为对象才能发动。那些卡回到手卡。那之后，可以从自己墓地把1只通常怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册苏生限制、手卡丢弃精准堆墓「塞尼特」卡、装备状态效破抗性以及解放通常怪兽弹对方场上卡并特召墓地通常怪兽效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把「塔乌塞尼特·阿贾特」以外的1张「塞尼特」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：有装备卡装备的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.eqcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，把自己场上最多3张表侧表示的通常怪兽卡送去墓地，以那个数量的对方场上的卡为对象才能发动。那些卡回到手卡。那之后，可以从自己墓地把1只通常怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 发动代价：把手卡的这张卡丢弃
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身作为代价从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中「塔乌塞尼特·阿贾特」以外可以送去墓地的「塞尼特」卡
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1eb) and c:IsAbleToGrave()
end
-- 从卡组送去墓地效果的发动条件检查与操作信息设置
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组是否存在除同名卡以外可以送去墓地的「塞尼特」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 从卡组把「塔乌塞尼特·阿贾特」以外的1张「塞尼特」卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择「塔乌塞尼特·阿贾特」以外的1张「塞尼特」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 检查自身是否有装备卡装备
function s.eqcon(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>0
end
-- 过滤自己场上表侧表示可以作为代价送去墓地的通常怪兽卡
function s.cfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 发动代价：把自己场上最多3张表侧表示通常怪兽卡送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为代价送去墓地的通常怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 获取对方场上可以作为对象返回手牌的卡片数量
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if rt>3 then rt=3 end
	-- 提示玩家选择要送去墓地的通常怪兽卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1到最多3张（不超过对方可取对象卡数）通常怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,rt,nil)
	-- 将选中的通常怪兽卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 回手牌效果的发动目标选择与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择送去墓地数量的对方场上的卡作为对象
	local tg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置操作信息：将选中的对象卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,ct,0,0)
end
-- 过滤墓地中可以特殊召唤的通常怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 使目标卡回到手卡，并可从自己墓地特殊召唤1只通常怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁建立联系的目标卡片
	local g=Duel.GetTargetsRelateToChain()
	-- 将对象卡返回手牌并确认操作成功
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
		-- 检查自己怪兽区域是否有可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在不受王长影响且可特殊召唤的通常怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否从墓地特殊召唤1只通常怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 分隔弹回手牌与特殊召唤的处理时点
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只通常怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的通常怪兽表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
