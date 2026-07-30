--ダイヤモンドダスト・サイクロン
-- 效果：
-- 选择雾指示物放置有4个以上的1只怪兽发动。把选择怪兽破坏，破坏怪兽每放置有4个雾指示物，从自己卡组抽1张卡。
function c19980975.initial_effect(c)
	-- origin_effect: 选择雾指示物放置有4个以上的1只怪兽发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19980975.target)
	e1:SetOperation(c19980975.activate)
	c:RegisterEffect(e1)
end
c19980975.mentioned_counter={
	[0x1019]=true,
}
-- 过滤函数：检查怪兽的雾指示物数量是否≥4
function c19980975.filter(c)
	return c:GetCounter(0x1019)>=4
end
-- target函数：检测效果发动的必要条件是否满足
function c19980975.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19980975.filter(chkc) end
	-- 检查玩家是否有效果抽卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查场上是否存在符合条件的怪兽（雾指示物≥4）
		and Duel.IsExistingTarget(c19980975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1只符合条件的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c19980975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，宣布破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- activate函数：破坏怪兽并根据雾指示物数量抽卡
function c19980975.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡（被选择的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=math.floor(tc:GetCounter(0x1019)/4)
		-- 如果破坏成功且雾指示物数量÷4的结果不为0
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and ct~=0 then
			-- 玩家从卡组抽ct张卡
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
