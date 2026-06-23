--ブライト・フューチャー
-- 效果：
-- 选择从游戏中除外的2只自己的念动力族怪兽发动。选择的怪兽回到墓地，从自己卡组抽1张卡。
function c24707869.initial_effect(c)
	-- 选择从游戏中除外的2只自己的念动力族怪兽发动。选择的怪兽回到墓地，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24707869.target)
	e1:SetOperation(c24707869.activate)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否表侧表示且属于念动力族
function c24707869.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 设置效果目标为除外区的2只自己的念动力族怪兽
function c24707869.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c24707869.filter(chkc) end
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查玩家除外区是否存在2只自己的念动力族怪兽
		and Duel.IsExistingTarget(c24707869.filter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择2只除外区的自己的念动力族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c24707869.filter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置效果处理信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果发动，将选择的怪兽送入墓地并抽1张卡
function c24707869.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的效果对象卡片组并筛选出与效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 then return end
	-- 将符合条件的怪兽以效果和回到墓地的原因送入墓地
	Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
	-- 让玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
