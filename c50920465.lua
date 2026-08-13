--ブリザード・サンダーバード
-- 效果：
-- 丢弃1张手卡才能发动。「雪暴雷鸟」以外的鸟兽族·水属性怪兽从自己的手卡·墓地各选1只特殊召唤。那之后，场上的这张卡回到持有者手卡。「雪暴雷鸟」的效果1回合只能使用1次。
function c50920465.initial_effect(c)
	-- 「丢弃1张手卡才能发动。「雪暴雷鸟」以外的鸟兽族·水属性怪兽从自己的手卡·墓地各选1只特殊召唤。那之后，场上的这张卡回到持有者手卡。「雪暴雷鸟」的效果1回合只能使用1次。」
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
-- 定义代价筛选函数：选择一张可丢弃的手卡，且除该卡以外手牌中至少还存在1只符合条件的「雪暴雷鸟」以外的鸟兽族·水属性怪兽，作为后续特殊召唤的对象。
function c50920465.cfilter(c,e,tp)
	-- 判断候选手卡可以被丢弃，并且手牌中存在另一张符合特殊召唤条件的鸟兽族·水属性怪兽（不是「雪暴雷鸟」）。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c50920465.filter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 代价函数：在发动时检查手牌中存在可丢弃的卡且保留有可特召对象；满足后实际丢弃1张手牌作为发动代价。
function c50920465.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：确认手牌中存在至少1张满足代价筛选条件的卡，即可丢弃且丢后仍有可特召对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c50920465.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 从手牌选择1张满足代价筛选条件的卡，以代价+丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c50920465.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
end
-- 定义可特殊召唤的怪兽筛选条件：鸟兽族、水属性、卡名不是「雪暴雷鸟」，且能被己方以此效果特殊召唤。
function c50920465.filter(c,e,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WATER)
		and not c:IsCode(50920465) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标/发动条件检测：确认没有「青眼精灵龙」的禁止同时特召效果生效，我方主怪兽区有2个以上空位，且墓地至少有1只符合条件的鸟兽族·水属性怪兽。
function c50920465.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查我方主怪兽区可用空格数大于1，确保能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查墓地存在至少1只符合条件的鸟兽族·水属性怪兽（「雪暴雷鸟」以外）。
		and Duel.IsExistingMatchingCard(c50920465.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将特殊召唤2只怪兽，来源为手牌和墓地，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：再次确认不受「青眼精灵龙」限制且有2个空格后，分别从手牌和墓地各选1只符合条件的怪兽，合并为1组同时特殊召唤；之后若这张卡仍与效果关联，则中断效果并将其返回持有者手卡。
function c50920465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次检查我方主怪兽区可用空格是否少于2个，若不足则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取手牌中所有符合条件的鸟兽族·水属性怪兽（「雪暴雷鸟」以外）的集合。
	local g1=Duel.GetMatchingGroup(c50920465.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取墓地中所有符合条件的鸟兽族·水属性怪兽（「雪暴雷鸟」以外），并用王家长眠之谷过滤器排除被其无效化的卡。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50920465.filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家从手牌选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 提示玩家从墓地选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将以选择的2只怪兽以表侧表示同时特殊召唤到己方场上。
	Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 中断当前效果链，使后续回手牌的处理与特殊召唤不在同一时点进行，防止错过时点。
		Duel.BreakEffect()
		-- 将效果发动的这张卡从场上返回持有者手卡，原因为效果。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
