--奇跡の蘇生
-- 效果：
-- 连锁4以后才能发动。从墓地选择1只怪兽，在自己场上特殊召唤。同1组连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
function c37011715.initial_effect(c)
	-- 创建效果，设置效果分类为特殊召唤，设置效果属性为取对象，设置效果类型为发动，设置效果时点为自由连锁，设置效果发动条件为连锁4以后且无同名卡发动，设置效果目标为c37011715.target，设置效果处理为c37011715.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c37011715.condition)
	e1:SetTarget(c37011715.target)
	e1:SetOperation(c37011715.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前连锁序号大于2且当前连锁中无同名卡发动
function c37011715.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁序号大于2且当前连锁中无同名卡发动
	return Duel.GetCurrentChain()>2 and Duel.CheckChainUniqueness()
end
-- 过滤函数：检查怪兽是否可以被特殊召唤
function c37011715.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：若chkc存在则检查其是否在墓地且可特殊召唤，若chk为0则检查场上是否有满足条件的墓地怪兽
function c37011715.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c37011715.filter(chkc,e,tp) end
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c37011715.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c37011715.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：获取目标怪兽并进行特殊召唤
function c37011715.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
