--「A」細胞散布爆弾
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「外星」的怪兽发动。选择的怪兽破坏，那只怪兽等级的数量的A指示物在对方场上表侧表示存在的怪兽放置。
function c73262676.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「外星」的怪兽发动。选择的怪兽破坏，那只怪兽等级的数量的A指示物在对方场上表侧表示存在的怪兽放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c73262676.target)
	e1:SetOperation(c73262676.operation)
	c:RegisterEffect(e1)
end
c73262676.counter_add_list={0x100e}
c73262676.mentioned_counter={
	[0x100e]=true,
}
-- 过滤条件：表侧表示且名字带有「外星」字段，并且等级大于0的怪兽。
function c73262676.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc) and c:GetLevel()>0
end
-- 效果对象设定：检查并要求玩家选择自己场上1只满足过滤条件的怪兽作为目标。
function c73262676.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c73262676.filter(chkc) end
	-- 检查自己场上是否存在1只满足过滤条件的怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c73262676.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可以放置「A」指示物的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 给己方发送提示信息：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1只满足过滤条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c73262676.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置破坏目标怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏目标怪兽，并根据其等级在对方场上表侧表示怪兽放置对应数量的「A」指示物。
function c73262676.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果发动的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 如果未能成功破坏目标怪兽，则中断效果处理。
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- 获取对方场上所有可以放置「A」指示物的怪兽集合。
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x100e,1)
		if g:GetCount()==0 then return end
		for i=1,lv do
			local sg=g:Select(tp,1,1,nil)
			sg:GetFirst():AddCounter(0x100e,1)
		end
	end
end
