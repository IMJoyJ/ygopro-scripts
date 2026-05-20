--騎甲虫スティンギー・ランス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己墓地1只昆虫族怪兽和对方墓地1只怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到持有者卡组最下面。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「骑甲虫」魔法·陷阱卡加入手卡。
function c65430555.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己墓地1只昆虫族怪兽和对方墓地1只怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65430555,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,65430555)
	e1:SetCondition(c65430555.spcon)
	e1:SetTarget(c65430555.sptg)
	e1:SetOperation(c65430555.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「骑甲虫」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65430555,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,65430556)
	e2:SetTarget(c65430555.thtg)
	e2:SetOperation(c65430555.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c65430555.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤自己墓地中可以回到卡组的昆虫族怪兽的条件函数
function c65430555.tdfilter1(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end
-- 过滤对方墓地中可以回到卡组的怪兽的条件函数
function c65430555.tdfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果①的发动准备与对象选择函数
function c65430555.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己墓地是否存在至少1只满足条件的昆虫族怪兽
		and Duel.IsExistingTarget(c65430555.tdfilter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c65430555.tdfilter2,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要回到卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只昆虫族怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c65430555.tdfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要回到卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1只怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c65430555.tdfilter2,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁信息：包含将2张卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	-- 设置连锁信息：包含将这张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数
function c65430555.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关联，以及自己场上是否有可用的怪兽区域
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE,0)<=0
		-- 将此卡特殊召唤，若特殊召唤失败则结束处理
		or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将作为对象的怪兽送回持有者卡组最下面
		Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 过滤卡组中可以加入手牌的「骑甲虫」魔法·陷阱卡的条件函数
function c65430555.schfilter(c)
	return c:IsSetCard(0x170) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备与检索目标检查函数
function c65430555.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「骑甲虫」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65430555.schfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理函数
function c65430555.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「骑甲虫」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c65430555.schfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
