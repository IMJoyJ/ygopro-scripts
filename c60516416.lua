--憑依共鳴－ウィン
-- 效果：
-- 魔法师族怪兽＋风属性怪兽
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡融合召唤的场合，从自己墓地让1只风属性怪兽回到卡组最下面，以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。
-- ②：对方回合，以包含自己场上的风属性怪兽的场上2张卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 初始化卡片效果注册
function s.initial_effect(c)
	-- 设置融合素材：魔法师族怪兽＋风属性怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WIND),true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合，从自己墓地让1只风属性怪兽回到卡组最下面，以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.cocon)
	e1:SetCost(s.cocost)
	e1:SetTarget(s.cotg)
	e1:SetOperation(s.coop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以包含自己场上的风属性怪兽的场上2张卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的触发条件函数，检查是否为融合召唤成功
function s.cocon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的发动Cost过滤函数，筛选墓地中可以回到卡组的风属性怪兽
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeckAsCost()
end
-- 效果①的Cost函数，处理从自己墓地让1只风属性怪兽回到卡组最下面
function s.cocost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在可以回到卡组的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只自己墓地中的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向对方玩家确认选择的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的怪兽送回卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果①的对象过滤函数，筛选对方场上可以改变控制权的怪兽
function s.filter(c,tp)
	return c:IsControlerCanBeChanged()
end
-- 效果①的target函数，选择改变控制权的对象并设置操作信息
function s.cotg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	-- 检查对方场上是否存在可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置改变控制权操作信息，表示让己方获得该对象怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果①的operation函数，处理获得对象怪兽控制权的操作
function s.coop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 让己方玩家获得该对象怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
-- 效果②的触发条件函数，检查是否为对方回合
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方的回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的卡片过滤函数，筛选自己场上表侧表示的风属性怪兽
function s.tdfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER)
end
-- 效果②的组检查函数，确保选择的2张卡中至少包含1张己方场上的风属性怪兽
function s.gcheck(g,tp)
	return g:IsExists(s.tdfilter,1,nil,tp)
end
-- 效果②的target函数，选择场上满足条件的2张卡作为对象，并设置回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有可以返回卡组且可以成为效果对象的卡片集合
	local rg=Duel.GetMatchingGroup(aux.AND(Card.IsAbleToDeck,Card.IsCanBeEffectTarget),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return rg:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local tg=rg:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将选中的两张卡片注册为效果对象
	Duel.SetTargetCard(tg)
	-- 设置回到卡组操作信息，表示将这两张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,2,0,0)
end
-- 效果②的operation函数，处理将场上对象卡以自选顺序回到卡组最下面的操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出仍然存在于场上的对象卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 让玩家以喜欢的顺序将这些卡片放置在卡组最下面
		aux.PlaceCardsOnDeckBottom(tp,tg)
	end
end
