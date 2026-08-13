--ハウスダストン
-- 效果：
-- ①：在场上的表侧表示的这张卡被对方的效果破坏送去墓地时或者在伤害步骤开始时是表侧表示的这张卡被和对方怪兽的战斗破坏送去墓地时才能发动。从手卡·卡组选「尘妖」怪兽任意数量在双方场上各相同数量特殊召唤。
function c40343749.initial_effect(c)
	-- ①：在场上的表侧表示的这张卡被对方的效果破坏送去墓地时或者在伤害步骤开始时是表侧表示的这张卡被和对方怪兽的战斗破坏送去墓地时才能发动。从手卡·卡组选「尘妖」怪兽任意数量在双方场上各相同数量特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40343749,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c40343749.condition)
	e1:SetTarget(c40343749.target)
	e1:SetOperation(c40343749.operation)
	c:RegisterEffect(e1)
end
-- 判断触发条件：若为战斗破坏，则必须是被对方怪兽战斗破坏且曾是表侧表示；若为效果破坏，则必须是对方的效果破坏、此卡此前表侧表示且在己方场上。
function c40343749.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) then
		return c:GetReasonPlayer()==1-tp and bit.band(c:GetBattlePosition(),POS_FACEUP)~=0
	end
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 筛选可特殊召唤的「尘妖」怪兽：卡名含有「尘妖」字段，并且既能以表侧表示特殊召唤到自己场上，也能以表侧表示特殊召唤到对方场上。
function c40343749.filter(c,e,tp)
	return c:IsSetCard(0x80) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果发动时的合法判定：确认没有【青眼精灵龙】的“双方不能把2只以上的怪兽同时特殊召唤”效果影响，双方主要怪兽区均有可用空位，且手卡·卡组中存在至少2只可特殊召唤到双方场上的「尘妖」怪兽；满足后登记特殊召唤操作信息。
function c40343749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认双方场上都有可用的主要怪兽区空格，以容纳特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 确认从手卡·卡组中至少存在2只满足c40343749.filter条件的「尘妖」怪兽（因为需要双方场上各相同数量，最少各1只）。
		and Duel.IsExistingMatchingCard(c40343749.filter,tp,LOCATION_DECK+LOCATION_HAND,0,2,nil,e,tp) end
	-- 登记本次连锁的特殊召唤操作信息：效果处理时将从手卡·卡组特殊召唤「尘妖」怪兽（预计至少2只，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：若【青眼精灵龙】效果生效则不能处理；计算双方可用的主要怪兽区空格数并取较小值；从手卡·卡组选出最多该数量的「尘妖」怪兽，先选一部分特殊召唤到自己场上，再选相同数量特殊召唤到对方场上，最后统一完成特殊召唤。
function c40343749.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取己方主要怪兽区当前可用的空格数量。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方主要怪兽区当前可用的空格数量。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft1<=0 or ft2<=0 then return end
	if ft1>ft2 then ft1=ft2 end
	-- 从手卡和卡组中筛选出所有满足条件的「尘妖」怪兽，构成可选的候选集合g。
	local g=Duel.GetMatchingGroup(c40343749.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local ct=math.floor(g:GetCount()/2)
	if ct==0 then return end
	if ct>ft1 then ct=ft1 end
	-- 向玩家显示选择提示，让玩家选择要特殊召唤到自己场上的「尘妖」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40343749,1))  --"请选择在自己场上特殊召唤的怪兽"
	local sg1=g:Select(tp,1,ct,nil)
	local tc=sg1:GetFirst()
	g:Sub(sg1)
	while tc do
		-- 将选中的一只「尘妖」怪兽以表侧表示特殊召唤到己方场上（特殊召唤分步处理）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc=sg1:GetNext()
	end
	local sg2=g:Select(tp,sg1:GetCount(),sg1:GetCount(),nil)
	tc=sg2:GetFirst()
	while tc do
		-- 将选中的一只「尘妖」怪兽以表侧表示特殊召唤到对方场上（特殊召唤分步处理）。
		Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP)
		tc=sg2:GetNext()
	end
	-- 结束分步特殊召唤，统一完成本连锁中所有「尘妖」怪兽的特殊召唤。
	Duel.SpecialSummonComplete()
end
