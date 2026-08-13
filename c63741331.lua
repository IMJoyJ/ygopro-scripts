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
c63741331.mentioned_counter={
	[0x1019]=true,
}
-- 代价过滤函数：检查怪兽是否是表侧表示且名字带有「云魔物」（0x18）
function c63741331.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 代价处理函数：确认存在可作为祭品的「云魔物」怪兽，让玩家选择1只并将其作为代价解放
function c63741331.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示、名字带有「云魔物」的可解放怪兽（用于确认能否支付代价）
	if chk==0 then return Duel.CheckReleaseGroup(tp,c63741331.cfilter,1,nil) end
	-- 让玩家从自己场上选择1只表侧表示、名字带有「云魔物」的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c63741331.cfilter,1,1,nil)
	-- 将选择的「云魔物」怪兽作为代价解放
	Duel.Release(g,REASON_COST)
end
-- 对象选择函数：确认双方场上各有可放置雾指示物的表侧表示怪兽，提示后让玩家选择1只表侧表示怪兽作为效果对象
function c63741331.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查双方场上是否存在至少2只可以放置3个雾指示物（0x1019）的表侧表示怪兽（确认效果可以发动）
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,0x1019,3) end
	-- 向玩家发送「请选择表侧表示的卡」的选择提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只可以放置3个雾指示物的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1019,3)
end
-- 效果处理函数：取得效果对象，若其仍是表侧表示且与本效果保持联系，则为其放置3个雾指示物
function c63741331.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,3)
	end
end
