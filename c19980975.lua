--ダイヤモンドダスト・サイクロン
-- 效果：
-- 选择雾指示物放置有4个以上的1只怪兽发动。把选择怪兽破坏，破坏怪兽每放置有4个雾指示物，从自己卡组抽1张卡。
function c19980975.initial_effect(c)
	-- 选择雾指示物放置有4个以上的1只怪兽发动。把选择怪兽破坏，破坏怪兽每放置有4个雾指示物，从自己卡组抽1张卡。
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
-- 定义筛选函数：检查卡片上放置的雾指示物数量是否达到4个以上
function c19980975.filter(c)
	return c:GetCounter(0x1019)>=4
end
-- 发动条件与对象检查：确认自己可以抽卡，且场上存在可作为效果对象的、放置有4个以上雾指示物的怪兽
function c19980975.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19980975.filter(chkc) end
	-- 检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查双方场上主要怪兽区是否存在可以取为对象的、放置有4个以上雾指示物的怪兽
		and Duel.IsExistingTarget(c19980975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己选择场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c19980975.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：登记本次连锁将破坏1只对象怪兽（破坏分类）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏对象怪兽，并按其放置的雾指示物每4个从卡组抽1张卡
function c19980975.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所指定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=math.floor(tc:GetCounter(0x1019)/4)
		-- 破坏对象怪兽，并确认实际破坏成功且雾指示物数量足以抽卡
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and ct~=0 then
			-- 自己从卡组抽ct张卡（每4个雾指示物抽1张）
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
