--紋章獣アバコーンウェイ
-- 效果：
-- 这张卡在墓地存在的场合，把这张卡以外的自己墓地1只「纹章兽 阿伯康韦龙」从游戏中除外才能发动。选择自己墓地1只名字带有「纹章兽」的怪兽加入手卡。「纹章兽 阿伯康韦龙」的效果1回合只能使用1次。
function c60316373.initial_effect(c)
	-- 这张卡在墓地存在的场合，把这张卡以外的自己墓地1只「纹章兽 阿伯康韦龙」从游戏中除外才能发动。选择自己墓地1只名字带有「纹章兽」的怪兽加入手卡。「纹章兽 阿伯康韦龙」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60316373,0))  --"回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,60316373)
	e1:SetCost(c60316373.cost)
	e1:SetTarget(c60316373.target)
	e1:SetOperation(c60316373.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中除自身以外的「纹章兽 阿伯康韦龙」且可以作为代价除外
function c60316373.rfilter(c)
	return c:IsCode(60316373) and c:IsAbleToRemoveAsCost()
end
-- 发动代价（Cost）：把这张卡以外的自己墓地1只「纹章兽 阿伯康韦龙」除外
function c60316373.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己墓地是否存在除自身以外的「纹章兽 阿伯康韦龙」可以作为代价除外
	if chk==0 then return Duel.IsExistingMatchingCard(c60316373.rfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只除自身以外的「纹章兽 阿伯康韦龙」
	local g=Duel.SelectMatchingCard(tp,c60316373.rfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的怪兽因发动代价而表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地中名字带有「纹章兽」的怪兽且可以加入手卡
function c60316373.filter(c)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标选择（Target）：选择自己墓地1只名字带有「纹章兽」的怪兽为对象
function c60316373.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c60316373.filter(chkc) end
	-- 判断自己墓地是否存在可以加入手卡的名字带有「纹章兽」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c60316373.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1只名字带有「纹章兽」的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60316373.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理（Operation）：将选择的怪兽加入手卡
function c60316373.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对应的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果且成功加入手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
