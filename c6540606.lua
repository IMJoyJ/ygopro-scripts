--水霊術－「葵」
-- 效果：
-- ①：把自己场上1只水属性怪兽解放才能发动。把对方手卡确认，从那之中选1张卡送去墓地。
function c6540606.initial_effect(c)
	-- ①：把自己场上1只水属性怪兽解放才能发动。把对方手卡确认，从那之中选1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCost(c6540606.cost)
	e1:SetTarget(c6540606.target)
	e1:SetOperation(c6540606.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：解放自己场上1只水属性怪兽
function c6540606.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放的水属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_WATER) end
	-- 让玩家选择自己场上1只水属性怪兽作为解放的卡
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_WATER)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果发动时的目标（Target）处理：检查对方手卡数量，并设置效果分类与操作信息
function c6540606.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否至少有1张
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息，表示此效果会将对方手卡的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理（Operation）阶段：确认对方手卡，并选择1张送去墓地
function c6540606.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家（即发动效果的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方的所有手卡
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 给发动效果的玩家确认对方的所有手卡
		Duel.ConfirmCards(p,g)
		-- 向发动效果的玩家提示“请选择要送去墓地的卡”
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的卡因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-p)
	end
end
