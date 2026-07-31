--フォッグ・コントロール
-- 效果：
-- 把自己表侧表示存在的1只名字带有「云魔物」的怪兽作为祭品，给场上表侧表示存在的1只怪兽放置3个雾指示物。
function c63741331.initial_effect(c)
	-- 把自己场上1只表侧表示的「云魔物」怪兽解放，以场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置3个雾指示物。
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
-- Cost解放怪兽过滤条件：自己场上表侧表示的「云魔物」怪兽
function c63741331.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 发动Cost处理：解放自己场上1只表侧表示的「云魔物」怪兽
function c63741331.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：自己场上是否存在可解放的表侧表示「云魔物」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c63741331.cfilter,1,nil) end
	-- 选择自己场上1只表侧表示的「云魔物」怪兽
	local g=Duel.SelectReleaseGroup(tp,c63741331.cfilter,1,1,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果发动准备与目标选择：选择场上1只表侧表示怪兽为对象
function c63741331.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件检查：场上是否存在至少2只可放置3个雾指示物的怪兽（需排除准备解放的怪兽）
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,0x1019,3) end
	-- 提示玩家选择要放置雾指示物的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1019,3)
end
-- 效果处理：给对象怪兽放置3个雾指示物
function c63741331.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1019,3)
	end
end
