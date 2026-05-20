--奇跡の復活
-- 效果：
-- 把自己场上2个魔力指示物取除才能发动。从自己墓地选择1只「黑魔术师」或者「破坏之剑士」特殊召唤。
function c68334074.initial_effect(c)
	-- 注册卡片密码，表示该卡的效果文本中记载了「黑魔术师」的卡名
	aux.AddCodeList(c,46986414)
	-- 把自己场上2个魔力指示物取除才能发动。从自己墓地选择1只「黑魔术师」或者「破坏之剑士」特殊召唤。
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
-- 效果发动的代价（Cost）函数：检查并移除自己场上的2个魔力指示物
function c68334074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以发动代价为原因移除2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 移除自己场上的2个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 过滤函数：筛选墓地中可以特殊召唤的「黑魔术师」或「破坏之剑士」
function c68334074.filter(c,e,tp)
	return c:IsCode(46986414,78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择（Target）函数：检查发动条件并选择墓地的目标怪兽
function c68334074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68334074.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的「黑魔术师」或「破坏之剑士」
		and Duel.IsExistingTarget(c68334074.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68334074.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1个目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理（Operation）函数：将选择的目标怪兽特殊召唤
function c68334074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
