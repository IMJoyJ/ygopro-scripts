--大儺主水
-- 效果：
-- 包含仪式怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以场上1张卡和自己墓地1只仪式怪兽为对象才能发动。那2张回到卡组。
-- ②：对方回合，把这张卡解放，以自己墓地1只仪式怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
function c73898890.initial_effect(c)
	-- 设置连接召唤手续：怪兽2只，且必须包含仪式怪兽
	aux.AddLinkProcedure(c,nil,2,2,c73898890.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以场上1张卡和自己墓地1只仪式怪兽为对象才能发动。那2张回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73898890,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,73898890)
	e1:SetTarget(c73898890.tdtg)
	e1:SetOperation(c73898890.tdop)
	c:RegisterEffect(e1)
	-- ②：对方回合，把这张卡解放，以自己墓地1只仪式怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73898890,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,73898891)
	e2:SetCost(c73898890.spcost)
	e2:SetCondition(c73898890.spcon)
	e2:SetTarget(c73898890.sptg)
	e2:SetOperation(c73898890.spop)
	c:RegisterEffect(e2)
end
-- 连接素材的检查函数：素材组中必须包含至少1只仪式怪兽
function c73898890.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_RITUAL)
end
-- 过滤自己墓地中可以回到卡组的仪式怪兽
function c73898890.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动判定与对象选择
function c73898890.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查自己墓地是否存在可以回到卡组的仪式怪兽
		and Duel.IsExistingTarget(c73898890.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张可以回到卡组的卡作为效果对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只可以回到卡组的仪式怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c73898890.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息为将选中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
end
-- ①效果的处理函数，将选中的卡送回卡组
function c73898890.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与当前连锁有关且可以回到卡组的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsAbleToDeck,nil)
	if #g==2 then
		-- 将这些卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数
function c73898890.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动代价函数
function c73898890.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中可以加入手卡或特殊召唤的仪式怪兽
function c73898890.spfilter(c,e,tp)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand()
			-- 或者在自身解放后有可用怪兽区域的情况下，该怪兽可以特殊召唤
			or Duel.GetMZoneCount(tp,e:GetHandler())>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的发动判定与对象选择
function c73898890.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73898890.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在可以加入手卡或特殊召唤的仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c73898890.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只仪式怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73898890.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
-- ②效果的处理函数
function c73898890.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查是否受到“王家长眠之谷”的影响而使效果无效
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 再次过滤确认对象卡片不受“王家长眠之谷”的影响
		if not aux.NecroValleyFilter()(tc) then return end
		-- 检查自己场上是否有空余怪兽区域，且该怪兽是否可以特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 如果不能加入手卡，或者玩家在“加入手卡”和“特殊召唤”中选择了“特殊召唤”
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将该怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将该怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
