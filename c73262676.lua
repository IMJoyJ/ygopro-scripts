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
-- 过滤自己场上表侧表示、等级大于0且卡名带有「外星」的怪兽
function c73262676.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc) and c:GetLevel()>0
end
-- 效果发动时的目标选择与合法性检测函数
function c73262676.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c73262676.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的「外星」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c73262676.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在至少1只可以放置A指示物的怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「外星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73262676.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，包含破坏1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的执行函数
function c73262676.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		-- 破坏目标怪兽，若破坏失败则不进行后续处理
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- 获取对方场上所有可以放置A指示物的怪兽
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x100e,1)
		if g:GetCount()==0 then return end
		for i=1,lv do
			local sg=g:Select(tp,1,1,nil)
			sg:GetFirst():AddCounter(0x100e,1)
		end
	end
end
