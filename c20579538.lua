--森羅の姫芽君 スプラウト
-- 效果：
-- 「森罗的姬芽君 幼芽」的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。自己卡组最上面的卡翻开送去墓地。那之后，可以选自己墓地1只「幼芽」怪兽在自己卡组最上面放置。
-- ②：卡组的这张卡被效果翻开送去墓地的场合，宣言1～8的任意等级才能发动。这张卡从墓地特殊召唤，这张卡的等级变成宣言的等级。
function c20579538.initial_effect(c)
	-- ①：把这张卡解放才能发动。自己卡组最上面的卡翻开送去墓地。那之后，可以选自己墓地1只「幼芽」怪兽在自己卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20579538,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20579538)
	e1:SetCost(c20579538.cost)
	e1:SetTarget(c20579538.target)
	e1:SetOperation(c20579538.operation)
	c:RegisterEffect(e1)
	-- ②：卡组的这张卡被效果翻开送去墓地的场合，宣言1～8的任意等级才能发动。这张卡从墓地特殊召唤，这张卡的等级变成宣言的等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20579538,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,20579539)
	e2:SetCondition(c20579538.spcon)
	e2:SetTarget(c20579538.sptg)
	e2:SetOperation(c20579538.spop)
	c:RegisterEffect(e2)
end
-- 支付效果代价：解放这张卡
function c20579538.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡从场上解放作为支付代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果的发动条件：确认玩家是否可以将卡组最上方的1张卡送去墓地
function c20579538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 过滤函数：筛选墓地里满足「幼芽」字段、怪兽类型且能送回卡组的卡片
function c20579538.tdfilter(c)
	return c:IsSetCard(0xa6) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 处理效果的主要流程：确认卡组最上方的1张卡并将其送去墓地，然后询问是否将墓地的「幼芽」怪兽送回卡组最上方
function c20579538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以将卡组最上方的1张卡送去墓地
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开玩家卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 禁止接下来的操作自动触发洗牌检测
	Duel.DisableShuffleCheck()
	-- 将翻开的卡送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)==0 then return end
	-- 从玩家墓地中筛选满足条件的「幼芽」怪兽
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20579538.tdfilter),tp,LOCATION_GRAVE,0,nil)
	-- 判断是否有满足条件的墓地怪兽，并询问玩家是否选择使用该效果
	if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20579538,2)) then  --"是否把自己墓地1只「幼芽」怪兽在卡组最上面放置"
		-- 中断当前效果处理流程，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要送回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tg=dg:Select(tp,1,1,nil)
		-- 显示所选卡片被选为对象的动画效果
		Duel.HintSelection(tg)
		-- 将选中的卡片送回卡组最上方
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 判断该卡是否因效果翻开而进入墓地
function c20579538.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 设置特殊召唤的条件：玩家场上是否有空位且该卡可被特殊召唤
function c20579538.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让玩家宣言1～8的任意等级
	local lv=Duel.AnnounceLevel(tp,1,8)
	e:SetLabel(lv)
	-- 设置连锁操作信息：准备特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并设置等级变更效果
function c20579538.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置该卡的等级变更效果，使其等级变为玩家宣言的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
