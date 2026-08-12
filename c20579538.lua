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
-- ①效果发动的代价处理：确认这张卡可以解放，并将其解放作为发动代价。
function c20579538.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放（作为效果发动的代价）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果发动的合法性检查：确认自己可以把卡组最上面的1张卡送去墓地。
function c20579538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认玩家可以把卡组顶端的1张卡送去墓地，否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 返回卡组对象的过滤条件：「幼芽」（森罗，0xa6）系列的怪兽卡且可以返回卡组。
function c20579538.tdfilter(c)
	return c:IsSetCard(0xa6) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ①效果处理：翻开自己卡组最上面的卡送去墓地，那之后可以选自己墓地1只「幼芽」怪兽在卡组最上面放置。
function c20579538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认可以把卡组顶端的1张卡送去墓地，不能则效果处理中断。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开（确认）自己卡组最上面的1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 取得自己卡组最上面的1张卡作为操作对象。
	local g=Duel.GetDecktopGroup(tp,1)
	-- 使接下来从卡组顶端取卡的操作不触发卡组洗切检测。
	Duel.DisableShuffleCheck()
	-- 把翻开的卡以效果（翻开）原因送去墓地，若没能送去墓地则中断后续处理。
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)==0 then return end
	-- 从自己墓地检索满足条件（「幼芽」怪兽、不受王家长眠之谷影响）的可返回卡组的卡。
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20579538.tdfilter),tp,LOCATION_GRAVE,0,nil)
	-- 若墓地存在可返回卡组的「幼芽」怪兽，询问玩家是否将其在卡组最上面放置。
	if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20579538,2)) then  --"是否把自己墓地1只「幼芽」怪兽在卡组最上面放置"
		-- 中断当前效果处理，使之后的处理视为不同时进行（避免错过时点）。
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local tg=dg:Select(tp,1,1,nil)
		-- 为选中的卡显示被选中的动画并记录选择。
		Duel.HintSelection(tg)
		-- 把选中的「幼芽」怪兽以效果原因在自己卡组最上面放置。
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡之前在卡组，且因翻开（森罗）原因被送去墓地。
function c20579538.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- ②效果发动的目标检查：确认自己主要怪兽区有空位，且这张卡可以特殊召唤。
function c20579538.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家宣言等级。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1～8的任意等级，并将宣言的等级记录下来。
	local lv=Duel.AnnounceLevel(tp,1,8)
	e:SetLabel(lv)
	-- 设置操作信息：本连锁将特殊召唤这张卡（供王家长眠之谷等效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：这张卡从墓地特殊召唤，且等级变成宣言的等级。
function c20579538.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与此效果关联，则将其从墓地以表侧表示特殊召唤到自己场上，成功则继续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这张卡的等级变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
