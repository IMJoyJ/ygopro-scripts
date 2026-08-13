--アングリーバーガー
-- 效果：
-- 「食谱」卡降临
-- 这个卡名在规则上当作「饥饿的汉堡」使用。这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「新式魔厨」怪兽加入手卡，这张卡回到卡组。
-- ②：可以攻击的对方怪兽必须向这张卡作出攻击。
-- ③：自己·对方回合可以发动。自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只攻击力2000的「饥饿的汉堡」特殊召唤。
local s,id,o=GetID()
-- 注册该卡的全部效果：①展示手牌检索「新式魔厨」并自身回卡组的起动效果；②对方怪兽必须攻击这张卡的永续效果；③解放场上攻击表示怪兽特殊召唤「饥饿的汉堡」的诱发即时效果。
function s.initial_effect(c)
	-- 记录这张卡在规则上也当作「饥饿的汉堡」（30243636）使用，以处理同名卡相关的规则限制。
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
-- 效果①的发动条件：这张卡在手牌处于非公开状态，即需要向对方展示手牌的这张卡才能发动。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索的过滤条件：属于「新式魔厨」系列（0x196）、是怪兽卡，并且可以加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的目标判定：检查卡组是否有符合条件的「新式魔厨」怪兽且这张卡自身能回卡组；同时设置处理时将检索卡加入手牌、自身回卡组的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果①发动时机的检查：卡组中存在至少1张满足s.thfilter的「新式魔厨」怪兽，且这张卡自身能够回到卡组。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck() end
	-- 设置连锁操作信息：本效果包含从卡组将1张卡加入手牌的处理，处理时再确定对象。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息：本效果包含将发动效果的这张卡自身送回卡组的处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 处理①效果：从卡组选择1只「新式魔厨」怪兽加入手牌；若检索成功且自身仍与连锁相关，则将这张卡返回卡组并洗切。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示框，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组中选择1张满足s.thfilter的「新式魔厨」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断检索是否成功：所选的卡存在、实际加入手牌成功，且所选卡确实位于手牌，满足条件才继续执行回卡组。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 将检索加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将效果持有者的这张卡送回持有者卡组，并触发卡组洗切。
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 指定强制攻击的对象为这张卡自身（EFFECT_MUST_ATTACK_MONSTER的判定函数）。
function s.atklimit(e,c)
	return c==e:GetHandler()
end
-- 解放候选的过滤条件：怪兽可被效果解放、处于攻击表示；若chk为真，还需解放后场上仍有可用的怪兽区。
function s.relfilter(c,tp,chk)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 若chk为真，要求解放该怪兽后tp场上仍有可用怪兽区，以保证后续特殊召唤能够进行。
		and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 特殊召唤目标的过滤条件：卡号为30243636（「饥饿的汉堡」）、攻击力为2000，并且能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(30243636) and c:IsAttack(2000)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果③的发动目标判定：场上存在1只可解放的攻击表示怪兽，同时手牌/卡组存在1只可特殊召唤的「饥饿的汉堡」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：场上存在1只满足s.relfilter的解放候选（且解放后仍有空位）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,true)
		-- 发动条件检查：手牌或卡组中存在1只满足s.spfilter的「饥饿的汉堡」可被特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本效果包含从手牌/卡组特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理③效果：选择1只攻击表示怪兽解放；解放成功且场上仍有可用的怪兽区时，从手牌/卡组选择1只「饥饿的汉堡」特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 显示选择解放怪兽的提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 获取场上所有满足解放条件且解放后仍能保留空位的怪兽组，优先从这些候选中选择。
	local rg=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,true)
	if rg:GetCount()>0 then
		g=rg:Select(tp,1,1,nil)
	else
		-- 若没有上述优先候选，则从场上所有可解放的攻击表示怪兽中选择1只（不检查解放后空位）。
		g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,false)
	end
	if g:GetCount()==0 then return end
	-- 为选中的解放怪兽展示选择动画，并将其记录为效果对象。
	Duel.HintSelection(g)
	-- 实际解放选中怪兽；若解放数量为0或解放后tp场上没有可用的怪兽区，则终止效果处理。
	if Duel.Release(g,REASON_EFFECT)==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	-- 显示选择特殊召唤怪兽的提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌/卡组选择1只满足s.spfilter的「饥饿的汉堡」作为特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的「饥饿的汉堡」以表侧攻击表示特殊召唤到tp的场上。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
