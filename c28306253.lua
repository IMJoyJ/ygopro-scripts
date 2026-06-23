--アングリーバーガー
-- 效果：
-- 「食谱」卡降临
-- 这个卡名在规则上当作「饥饿的汉堡」使用。这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「新式魔厨」怪兽加入手卡，这张卡回到卡组。
-- ②：可以攻击的对方怪兽必须向这张卡作出攻击。
-- ③：自己·对方回合可以发动。自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只攻击力2000的「饥饿的汉堡」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册饥饿的汉堡的代码列表，启用复活限制，并创建三个效果
function s.initial_effect(c)
	-- 将该卡注册为“饥饿的汉堡”的同名卡，用于规则上的等效处理
	aux.AddCodeList(c,30243636)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「新式魔厨」怪兽加入手卡，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：可以攻击的对方怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合可以发动。自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只攻击力2000的「饥饿的汉堡」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 效果发动时的费用处理，确认手卡的这张卡对对手可见
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤器，用于筛选「新式魔厨」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动条件与处理信息设置，检查卡组是否存在符合条件的怪兽并确认该卡可送回卡组
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在符合条件的「新式魔厨」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck() end
	-- 设置连锁操作信息，表示将从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息，表示将该卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果的处理函数，执行检索与送回卡组的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并确认对手可见
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 向对手确认所选的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将该卡送回卡组并洗牌
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 攻击限制效果的值函数，使只有该卡本身才能被强制攻击
function s.atklimit(e,c)
	return c==e:GetHandler()
end
-- 解放过滤器，用于筛选可被解放的攻击表示怪兽
function s.relfilter(c,tp,chk)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 判断是否满足解放怪兽的区域条件
		and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 特殊召唤过滤器，用于筛选攻击力为2000的「饥饿的汉堡」
function s.spfilter(c,e,tp)
	return c:IsCode(30243636) and c:IsAttack(2000)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的发动条件与处理信息设置，检查场上是否有可解放的怪兽和手卡/卡组中是否有符合条件的汉堡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在可解放的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,true)
		-- 检查手卡或卡组中是否存在符合条件的「饥饿的汉堡」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤一张符合条件的汉堡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的处理函数，执行解放与特殊召唤的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 获取场上所有可被解放的攻击表示怪兽
	local rg=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,true)
	if rg:GetCount()>0 then
		g=rg:Select(tp,1,1,nil)
	else
		-- 若无满足条件的怪兽，则手动选择一张
		g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,false)
	end
	if g:GetCount()==0 then return end
	-- 显示所选的怪兽被作为对象
	Duel.HintSelection(g)
	-- 判断是否成功解放怪兽并检查场上是否有召唤区域
	if Duel.Release(g,REASON_EFFECT)==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	-- 提示玩家选择要特殊召唤的汉堡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择一张符合条件的汉堡
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的汉堡以特殊召唤方式送入场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
