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
	-- 启用灵摆卡的基本属性与发动画框
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从自己的额外卡组让「魔导兽 巴西利斯克」以外的1只表侧表示的魔法师族灵摆怪兽回到卡组。那之后，自己从卡组抽1张。
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
	-- 注册自定义活动标记：在连锁发动时记录卡片发动状态
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 连锁注册处理：为当前发动的卡设定连锁标记
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
	-- ②：把自己场上3个魔力指示物去除才能发动。从自己的灵摆区域的卡以及自己的额外卡组的表侧表示的灵摆怪兽之中选1张「魔导兽」卡回到持有者手卡。
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
c80959027.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果发动条件：另一边的自己灵摆区域没有卡
function c80959027.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在除自身外的其他卡
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 回收过滤条件：「魔导兽 巴西利斯克」以外的表侧表示魔法师族灵摆怪兽且可回到卡组
function c80959027.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and not c:IsCode(80959027) and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 灵摆效果发动准备：检查破坏、卡组回收及抽卡条件，并设置操作信息
function c80959027.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 检查额外卡组是否存在符合条件的魔法师族灵摆怪兽
		and Duel.IsExistingMatchingCard(c80959027.tdfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查玩家是否可以抽1张卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置连锁操作信息：从额外卡组选1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 灵摆效果处理：破坏自身，从额外卡组将1只符合条件的怪兽放回卡组，随后抽1张卡
function c80959027.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否关联连锁并成功被效果破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从额外卡组选择1只表侧表示魔法师族灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c80959027.tdfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		-- 成功将选中的卡洗回卡组
		if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 连接效果块（分隔洗回卡组与抽卡处理）
			Duel.BreakEffect()
			-- 洗切卡组
			Duel.ShuffleDeck(tp)
			-- 从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 放置指示物处理：魔法卡发动处理时给自身放置1个魔力指示物
function c80959027.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 加手过滤条件：表侧表示的「魔导兽」卡且可加入手牌
function c80959027.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10d) and c:IsAbleToHand()
end
-- 怪兽②效果Cost：去除场上3个魔力指示物
function c80959027.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Cost检查：自己场上是否存在至少3个可去除的魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 从自己场上去除3个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 怪兽②效果准备：设置将灵摆区/额外卡组的「魔导兽」卡加入手牌的操作信息
function c80959027.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：灵摆区域或额外卡组是否存在符合条件的表侧「魔导兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80959027.thfilter,tp,LOCATION_PZONE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：从灵摆区/额外卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_PZONE+LOCATION_EXTRA)
end
-- 怪兽②效果处理：选择灵摆区或额外卡组1张表侧「魔导兽」卡回到手卡
function c80959027.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从灵摆区域或额外卡组选择1张表侧表示「魔导兽」卡
	local g=Duel.SelectMatchingCard(tp,c80959027.thfilter,tp,LOCATION_PZONE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
