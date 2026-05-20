--デビル・コメディアン
-- 效果：
-- ①：进行1次投掷硬币，对硬币的里表作猜测。猜中的场合，对方墓地的卡全部除外。猜错的场合，把对方墓地的卡数量的卡从自己卡组上面送去墓地。
function c81172176.initial_effect(c)
	-- ①：进行1次投掷硬币，对硬币的里表作猜测。猜中的场合，对方墓地的卡全部除外。猜错的场合，把对方墓地的卡数量的卡从自己卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_REMOVE+CATEGORY_DECKDES+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81172176.target)
	e1:SetOperation(c81172176.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的可行性检查：对方墓地有可以除外的卡，且自己卡组的卡数量不少于对方墓地的卡数量
function c81172176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		-- 并且检查自己卡组的卡片数量是否大于或等于对方墓地的卡片数量
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE) end
	-- 设置操作信息为进行1次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理：进行硬币猜测，根据结果除外对方墓地的卡或将自己卡组的卡送去墓地
function c81172176.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 玩家进行硬币正反面的宣言
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币并获取结果
	local res=Duel.TossCoin(tp,1)
	-- 若猜中，则将对方墓地的卡全部表侧表示除外
	if coin~=res then Duel.Remove(Duel.GetFieldGroup(tp,0,LOCATION_GRAVE),POS_FACEUP,REASON_EFFECT)
	-- 若猜错，则将对方墓地卡片数量的卡从自己卡组上面送去墓地
	else Duel.DiscardDeck(tp,Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE),REASON_EFFECT) end
end
