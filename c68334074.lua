--奇跡の復活
-- 效果：
-- 把自己场上2个魔力指示物取除才能发动。从自己墓地选择1只「黑魔术师」或者「破坏之剑士」特殊召唤。
function c68334074.initial_effect(c)
	-- 记录这张卡上记载着「黑魔术师」的卡名
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
-- 发动的代价：确认并把自己场上2个魔力指示物取除
function c68334074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动检查时，确认自己场上存在可以取除的2个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) end
	-- 作为发动代价，把自己场上2个魔力指示物取除
	Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
end
-- 对象筛选条件：卡名为「黑魔术师」或「破坏之剑士」且可以被特殊召唤的怪兽
function c68334074.filter(c,e,tp)
	return c:IsCode(46986414,78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象阶段：确认对象在自己墓地且由自己控制并满足筛选条件；效果发动检查时确认自己有可用的主要怪兽区空格且墓地存在可选择的对象
function c68334074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68334074.filter(chkc,e,tp) end
	-- 效果发动检查时，确认自己的主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认自己墓地存在可以作为对象的满足条件的卡
		and Duel.IsExistingTarget(c68334074.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只「黑魔术师」或者「破坏之剑士」作为效果对象
	local g=Duel.SelectTarget(tp,c68334074.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息：将对象卡特殊召唤，用于其他效果对这次特殊召唤的检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与效果相关联，则将其在自己场上表侧表示特殊召唤
function c68334074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁效果选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
