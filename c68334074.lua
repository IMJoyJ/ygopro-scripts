--奇跡の復活
-- 效果：
-- 把自己场上2个魔力指示物取除才能发动。从自己墓地选择1只「黑魔术师」或者「破坏之剑士」特殊召唤。
function c68334074.initial_effect(c)
	-- 注册卡片关联密码：「黑魔术师」(46986414)
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
c68334074.mentioned_counter={
	[0x1]=true,
}
-- 发动Cost处理：取除2个魔力指示物
function c68334074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：场上是否存在至少2个可取除的魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 从己方场上取除2个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 特殊召唤目标过滤条件：墓地的「黑魔术师」或「破坏之剑士」且可特殊召唤
function c68334074.filter(c,e,tp)
	return c:IsCode(46986414,78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动准备与选择目标：检查怪兽区域与墓地目标，并选择1只对象怪兽
function c68334074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68334074.filter(chkc,e,tp) end
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：墓地是否存在可特殊召唤的「黑魔术师」或「破坏之剑士」
		and Duel.IsExistingTarget(c68334074.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只「黑魔术师」或「破坏之剑士」作为连锁对象
	local g=Duel.SelectTarget(tp,c68334074.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽表侧表示特殊召唤
function c68334074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁选定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
