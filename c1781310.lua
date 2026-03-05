--風林火山
-- 效果：
-- ①：风·水·炎·地属性怪兽在场上全部存在的场合才能发动。从以下效果选1个适用。
-- ●对方场上的怪兽全部破坏。
-- ●对方场上的魔法·陷阱卡全部破坏。
-- ●对方手卡随机选2张丢弃。
-- ●自己从卡组抽2张。
function c1781310.initial_effect(c)
	-- 效果原文内容：①：风·水·炎·地属性怪兽在场上全部存在的场合才能发动。从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_TOHAND)
	e1:SetCondition(c1781310.condition)
	e1:SetTarget(c1781310.target)
	e1:SetOperation(c1781310.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在指定属性的表侧表示怪兽
function c1781310.cfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 效果作用：过滤魔法·陷阱卡
function c1781310.dfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：判断是否满足发动条件，即场上同时存在风·水·炎·地属性的表侧表示怪兽
function c1781310.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否存在风属性的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c1781310.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WIND)
		-- 效果作用：判断场上是否存在水属性的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c1781310.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WATER)
		-- 效果作用：判断场上是否存在炎属性的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c1781310.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_FIRE)
		-- 效果作用：判断场上是否存在地属性的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c1781310.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_EARTH)
end
-- 效果作用：判断是否满足发动条件，即满足以下任意一项：对方场上存在怪兽、对方场上存在魔法·陷阱卡、对方手牌数量大于等于2、自己可以抽2张卡
function c1781310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 效果作用：判断对方场上是否存在魔法·陷阱卡
		or Duel.IsExistingMatchingCard(c1781310.dfilter2,tp,0,LOCATION_ONFIELD,1,nil)
		-- 效果作用：判断对方手牌数量是否大于等于2
		or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=2
		-- 效果作用：判断自己是否可以抽2张卡
		or Duel.IsPlayerCanDraw(tp,2) end
end
-- 效果作用：根据满足条件的选项，选择并执行对应效果
function c1781310.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	-- 效果作用：判断对方场上是否存在怪兽，若存在则添加选项“对方场上怪兽全部破坏”
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		ops[off]=aux.Stringid(1781310,0)  --"对方场上怪兽全部破坏"
		opval[off-1]=1
		off=off+1
	end
	-- 效果作用：判断对方场上是否存在魔法·陷阱卡，若存在则添加选项“对方场上魔法·陷阱卡全部破坏”
	if Duel.IsExistingMatchingCard(c1781310.dfilter2,tp,0,LOCATION_ONFIELD,1,nil) then
		ops[off]=aux.Stringid(1781310,1)  --"对方场上魔法·陷阱卡全部破坏"
		opval[off-1]=2
		off=off+1
	end
	-- 效果作用：判断对方手牌数量是否大于等于2，若满足则添加选项“对方随机丢弃2张手卡”
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=2 then
		ops[off]=aux.Stringid(1781310,2)  --"对方随机丢弃2张手卡"
		opval[off-1]=3
		off=off+1
	end
	-- 效果作用：判断自己是否可以抽2张卡，若满足则添加选项“抽2张卡”
	if Duel.IsPlayerCanDraw(tp,2) then
		ops[off]=aux.Stringid(1781310,3)  --"抽2张卡"
		opval[off-1]=4
		off=off+1
	end
	if off==1 then return end
	-- 效果作用：让玩家选择一个效果选项
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		-- 效果作用：获取对方场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 效果作用：将对方场上的所有怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	elseif opval[op]==2 then
		-- 效果作用：获取对方场上的所有魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c1781310.dfilter2,tp,0,LOCATION_ONFIELD,nil)
		-- 效果作用：将对方场上的所有魔法·陷阱卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	elseif opval[op]==3 then
		-- 效果作用：随机选择对方的2张手牌
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(1-tp,2)
		-- 效果作用：将随机选中的2张手牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	elseif opval[op]==4 then
		-- 效果作用：自己从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
