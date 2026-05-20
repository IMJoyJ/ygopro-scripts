--フォッグ・コントロール
-- 效果：
-- 把自己表侧表示存在的1只名字带有「云魔物」的怪兽作为祭品，给场上表侧表示存在的1只怪兽放置3个雾指示物。
function c63741331.initial_effect(c)
	-- 把自己表侧表示存在的1只名字带有「云魔物」的怪兽作为祭品，给场上表侧表示存在的1只怪兽放置3个雾指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c63741331.cost)
	e1:SetTarget(c63741331.target)
	e1:SetOperation(c63741331.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且卡名带有「云魔物」的怪兽
function c63741331.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 发动代价：解放自己场上1只表侧表示的「云魔物」怪兽
function c63741331.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付解放1只表侧表示「云魔物」怪兽的代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,c63741331.cfilter,1,nil) end
	-- 玩家选择1只用于解放的表侧表示「云魔物」怪兽
	local g=Duel.SelectReleaseGroup(tp,c63741331.cfilter,1,1,nil)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果的目标：选择场上1只表侧表示的怪兽
function c63741331.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少2只可以放置3个雾指示物的表侧表示怪兽（确保解放1只后仍有可选对象）
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,0x1019,3) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只可以放置3个雾指示物的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1019,3)
end
-- 效果的处理：给选择的对象怪兽放置3个雾指示物
function c63741331.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,3)
	end
end
