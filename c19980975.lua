--ダイヤモンドダスト・サイクロン
-- 效果：
-- 选择雾指示物放置有4个以上的1只怪兽发动。把选择怪兽破坏，破坏怪兽每放置有4个雾指示物，从自己卡组抽1张卡。
function c19980975.initial_effect(c)
	-- 效果原文内容：选择雾指示物放置有4个以上的1只怪兽发动。把选择怪兽破坏，破坏怪兽每放置有4个雾指示物，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19980975.target)
	e1:SetOperation(c19980975.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽（场上放置有4个以上雾指示物的怪兽）
function c19980975.filter(c)
	return c:GetCounter(0x1019)>=4
end
-- 效果作用：选择满足条件的怪兽作为对象
function c19980975.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19980975.filter(chkc) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c19980975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c19980975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：处理破坏和抽卡效果
function c19980975.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=math.floor(tc:GetCounter(0x1019)/4)
		-- 破坏对象怪兽并判断是否满足抽卡条件
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and ct~=0 then
			-- 从自己卡组抽指定数量的卡
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
