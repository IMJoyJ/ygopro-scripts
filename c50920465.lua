--ブリザード・サンダーバード
-- 效果：
-- 丢弃1张手卡才能发动。「雪暴雷鸟」以外的鸟兽族·水属性怪兽从自己的手卡·墓地各选1只特殊召唤。那之后，场上的这张卡回到持有者手卡。「雪暴雷鸟」的效果1回合只能使用1次。
function c50920465.initial_effect(c)
	-- 丢弃1张手卡才能发动。「雪暴雷鸟」以外的鸟兽族·水属性怪兽从自己的手卡·墓地各选1只特殊召唤。那之后，场上的这张卡回到持有者手卡。「雪暴雷鸟」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50920465,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50920465)
	e1:SetCost(c50920465.cost)
	e1:SetTarget(c50920465.target)
	e1:SetOperation(c50920465.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手牌是否可以被丢弃，并且自己手牌中是否存在满足条件的鸟兽族·水属性怪兽。
function c50920465.cfilter(c,e,tp)
	-- 返回值为true表示该卡可被丢弃，并且在自己的手牌中存在满足filter条件的卡。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c50920465.filter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 设置效果的发动费用：丢弃1张手卡，丢弃的卡必须满足cfilter条件。
function c50920465.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己手牌中是否存在满足cfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c50920465.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 执行丢弃操作：从玩家手牌中选择并丢弃1张满足cfilter条件的卡。
	Duel.DiscardHand(tp,c50920465.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
end
-- 过滤函数，用于筛选鸟兽族·水属性且不是雪暴雷鸟的怪兽，并且可以被特殊召唤。
function c50920465.filter(c,e,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WATER)
		and not c:IsCode(50920465) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件：检测是否受到青眼精灵龙效果影响、场上是否有足够的召唤位置、墓地是否存在满足条件的怪兽。
function c50920465.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否处于青眼精灵龙效果影响下，若处于则不能发动此效果；同时检查自己场上的召唤位置是否大于1。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地中是否存在至少1张满足filter条件的怪兽。
		and Duel.IsExistingMatchingCard(c50920465.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：表示本次效果将特殊召唤2只怪兽（1只来自手牌，1只来自墓地）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行效果处理函数：检测是否受到青眼精灵龙影响、是否有足够召唤位置、获取满足条件的卡组并选择后进行特殊召唤。
function c50920465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的召唤位置是否小于2，若不足则不能发动此效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取自己手牌中所有满足filter条件的怪兽组成集合g1。
	local g1=Duel.GetMatchingGroup(c50920465.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取自己墓地中所有满足filter条件（排除王家长眠之谷影响）的怪兽组成集合g2。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50920465.filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡，显示“请选择要特殊召唤的卡”的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 提示玩家选择要特殊召唤的卡，显示“请选择要特殊召唤的卡”的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将选中的2只怪兽（sg1）以正面表示方式特殊召唤到自己场上。
	Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 中断当前效果处理流程，使后续处理视为错时点。
		Duel.BreakEffect()
		-- 将此卡送回持有者手牌。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
