--メガリス・アラトロン
-- 效果：
-- 「巨石遗物」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只「巨石遗物」仪式怪兽仪式召唤。
-- ②：自己场上的卡为对象的对方的效果发动时才能发动。从自己墓地选1只仪式怪兽回到卡组最下面，那个发动无效并破坏。
function c25726386.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册一个仪式召唤效果，条件为等级合计直到变成仪式召唤的怪兽的等级以上为止，从手卡将符合条件的仪式怪兽仪式召唤
	local e1=aux.AddRitualProcGreater2(c,c25726386.filter,nil,nil,c25726386.matfilter,true)
	e1:SetDescription(aux.Stringid(25726386,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,25726386)
	e1:SetCondition(c25726386.rscon)
	e1:SetCost(c25726386.rscost)
	c:RegisterEffect(e1)
	-- 自己场上的卡为对象的对方的效果发动时才能发动。从自己墓地选1只仪式怪兽回到卡组最下面，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25726386,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25726387)
	e2:SetCondition(c25726386.discon)
	e2:SetTarget(c25726386.distg)
	e2:SetOperation(c25726386.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可以被仪式召唤的「巨石遗物」仪式怪兽
function c25726386.filter(c,e,tp,chk)
	return c:IsSetCard(0x138) and (not chk or c~=e:GetHandler())
end
-- 过滤函数，用于筛选可作为祭品的怪兽素材
function c25726386.matfilter(c,e,tp,chk)
	return not chk or c~=e:GetHandler()
end
-- 判断是否处于主要阶段1或主要阶段2
function c25726386.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 设置仪式召唤的发动费用，将自身从手卡丢弃
function c25726386.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手卡丢弃到墓地作为仪式召唤的费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断卡是否在场上且属于指定玩家
function c25726386.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 过滤函数，用于筛选可以送回卡组的仪式怪兽
function c25726386.disfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足效果发动条件，即对方发动效果且该效果有目标卡，且目标卡中有我方场上的卡，且该效果可以被无效
function c25726386.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡组信息
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断当前连锁的目标卡组中是否存在我方场上的卡，且该连锁可以被无效
	return tg and tg:IsExists(c25726386.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 设置效果发动时的操作信息，包括将墓地的仪式怪兽送回卡组、使效果无效、破坏对方效果的发动对象
function c25726386.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即我方墓地存在至少1张可送回卡组的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25726386.disfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表示将1张墓地的仪式怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息，表示使当前连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示破坏对方效果的发动对象
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理效果发动时的操作，选择1张墓地的仪式怪兽送回卡组最底端，若成功则使该连锁无效并破坏对方效果的发动对象
function c25726386.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张满足条件的墓地仪式怪兽作为送回卡组的对象
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25726386.disfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 判断是否成功将仪式怪兽送回卡组最底端
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 then
		-- 判断送回卡组的仪式怪兽是否在卡组中，且连锁可以被无效，且对方效果的发动对象仍然有效
		if g:GetFirst():IsLocation(LOCATION_DECK) and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏对方效果的发动对象
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
