--奇跡の復活
-- 效果：
-- 把自己场上2个魔力指示物取除才能发动。从自己墓地选择1只「黑魔术师」或者「破坏之剑士」特殊召唤。
function c68334074.initial_effect(c)
	-- 注册卡片效果中包含的其他卡名，此处记录了黑魔术师的卡号
	aux.AddCodeList(c,46986414)
	-- 把自分场上2个魔力指示物取除才能发动。从自己墓地选择1只「黑魔术师」或者「破坏之剑士」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c68334074.cost)
	e1:SetTarget(c68334074.target)
	e1:SetOperation(c68334074.activate)
	c:RegisterEffect(e1)
end
c68334074.mentioned_counter={
	[0x1]=true,
}
-- 费用函数：检查是否可以移除2个魔力指示物并执行移除操作
function c68334074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以移除2个魔力指示物作为发动代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 实际移除2个魔力指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 过滤函数：筛选墓地中的黑魔术师或破坏之剑士卡片
function c68334074.filter(c,e,tp)
	return c:IsCode(46986414,78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：设定效果的目标为己方墓地中的符合条件的怪兽
function c68334074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68334074.filter(chkc,e,tp) end
	-- 判断己方场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地中是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c68334074.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片并设置为效果对象
	local g=Duel.SelectTarget(tp,c68334074.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表明将要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 发动函数：处理效果的最终执行，将选中的怪兽特殊召唤
function c68334074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片正面表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
