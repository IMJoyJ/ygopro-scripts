--ハウスダストン
-- 效果：
-- ①：在场上的表侧表示的这张卡被对方的效果破坏送去墓地时或者在伤害步骤开始时是表侧表示的这张卡被和对方怪兽的战斗破坏送去墓地时才能发动。从手卡·卡组选「尘妖」怪兽任意数量在双方场上各相同数量特殊召唤。
function c40343749.initial_effect(c)
	-- 效果原文：①：在场上的表侧表示的这张卡被对方的效果破坏送去墓地时或者在伤害步骤开始时是表侧表示的这张卡被和对方怪兽的战斗破坏送去墓地时才能发动。从手卡·卡组选「尘妖」怪兽任意数量在双方场上各相同数量特殊召唤。
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
-- 规则层面：判断是否满足发动条件，即被对方效果破坏或在伤害步骤开始时被对方怪兽战斗破坏且为表侧表示。
function c40343749.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) then
		return c:GetReasonPlayer()==1-tp and bit.band(c:GetBattlePosition(),POS_FACEUP)~=0
	end
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 规则层面：过滤满足条件的「尘妖」怪兽，确保其可以被特殊召唤到自己和对方场上。
function c40343749.filter(c,e,tp)
	return c:IsSetCard(0x80) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 规则层面：检查是否满足发动条件，包括未受青眼精灵龙影响、双方场上都有空位、手卡或卡组存在至少2只符合条件的怪兽。
function c40343749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面：检查自己和对方的怪兽区域是否都有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 规则层面：检查手卡或卡组中是否存在至少2只符合条件的「尘妖」怪兽。
		and Duel.IsExistingMatchingCard(c40343749.filter,tp,LOCATION_DECK+LOCATION_HAND,0,2,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤2只怪兽到双方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 规则层面：执行效果处理，先检查是否受青眼精灵龙影响，然后计算可特殊召唤的数量并进行选择和特殊召唤。
function c40343749.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 规则层面：获取自己场上的可用怪兽区域数量。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 规则层面：获取对方场上的可用怪兽区域数量。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft1<=0 or ft2<=0 then return end
	if ft1>ft2 then ft1=ft2 end
	-- 规则层面：获取手卡和卡组中所有符合条件的「尘妖」怪兽。
	local g=Duel.GetMatchingGroup(c40343749.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local ct=math.floor(g:GetCount()/2)
	if ct==0 then return end
	if ct>ft1 then ct=ft1 end
	-- 规则层面：提示玩家选择在自己场上特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40343749,1))  --"请选择在自己场上特殊召唤的怪兽"
	local sg1=g:Select(tp,1,ct,nil)
	local tc=sg1:GetFirst()
	g:Sub(sg1)
	while tc do
		-- 规则层面：将选中的怪兽特殊召唤到自己场上。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc=sg1:GetNext()
	end
	local sg2=g:Select(tp,sg1:GetCount(),sg1:GetCount(),nil)
	tc=sg2:GetFirst()
	while tc do
		-- 规则层面：将剩余选中的怪兽特殊召唤到对方场上。
		Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP)
		tc=sg2:GetNext()
	end
	-- 规则层面：完成所有特殊召唤步骤，结束效果处理。
	Duel.SpecialSummonComplete()
end
