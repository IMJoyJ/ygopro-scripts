--魔導獣 バジリスク
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组让「魔导兽 巴西利斯克冠蜥」以外的1只表侧表示的魔法师族灵摆怪兽回到卡组。那之后，自己从卡组抽1张。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把自己场上3个魔力指示物取除才能发动。从自己的灵摆区域的卡以及自己的额外卡组的表侧表示的灵摆怪兽之中选1张「魔导兽」卡回到持有者手卡。
function c80959027.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组让「魔导兽 巴西利斯克冠蜥」以外的1只表侧表示的魔法师族灵摆怪兽回到卡组。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80959027,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,80959027)
	e1:SetCondition(c80959027.tdcon)
	e1:SetTarget(c80959027.tdtg)
	e1:SetOperation(c80959027.tdop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 在连锁发生时，记录这张卡在场上存在，用于后续魔力指示物放置的判定
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c80959027.acop)
	c:RegisterEffect(e3)
	-- ②：把自己场上3个魔力指示物取除才能发动。从自己的灵摆区域的卡以及自己的额外卡组的表侧表示的灵摆怪兽之中选1张「魔导兽」卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80959027,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,80959028)
	e4:SetCost(c80959027.thcost)
	e4:SetTarget(c80959027.thtg)
	e4:SetOperation(c80959027.thop)
	c:RegisterEffect(e4)
end
-- 灵摆效果的发动条件判定函数
function c80959027.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的自己的灵摆区域是否存在卡片（若不存在则满足发动条件）
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤额外卡组中表侧表示的、除「魔导兽 巴西利斯克冠蜥」以外的魔法师族灵摆怪兽
function c80959027.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and not c:IsCode(80959027) and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 灵摆效果的发动目标与可行性检查函数
function c80959027.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 检查额外卡组是否存在满足条件的魔法师族灵摆怪兽
		and Duel.IsExistingMatchingCard(c80959027.tdfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁处理信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置连锁处理信息：从额外卡组让1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁处理信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 灵摆效果的效果处理函数
function c80959027.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍存在并尝试将其破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 提示玩家选择要返回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 玩家从额外卡组选择1张满足条件的表侧表示魔法师族灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c80959027.tdfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		-- 将选中的卡送回卡组并洗卡，若成功则继续处理
		if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续的抽卡处理不与回卡组同时进行
			Duel.BreakEffect()
			-- 洗切玩家卡组
			Duel.ShuffleDeck(tp)
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 魔法卡发动成功时，为这张卡放置1个魔力指示物的效果处理函数
function c80959027.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 过滤灵摆区或额外卡组中表侧表示的、可以加入手牌的「魔导兽」卡片
function c80959027.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsAbleToHand()
end
-- 怪兽效果②的发动代价（Cost）处理函数
function c80959027.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否能移去3个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 移去自己场上的3个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 怪兽效果②的发动目标与可行性检查函数
function c80959027.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域或额外卡组中是否存在可加入手牌的「魔导兽」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c80959027.thfilter,tp,LOCATION_PZONE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_PZONE+LOCATION_EXTRA)
end
-- 怪兽效果②的效果处理函数
function c80959027.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从自己的灵摆区域或额外卡组中选择1张「魔导兽」卡片
	local g=Duel.SelectMatchingCard(tp,c80959027.thfilter,tp,LOCATION_PZONE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
