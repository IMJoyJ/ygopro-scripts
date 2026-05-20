--ローズ・バード
-- 效果：
-- 场上表侧攻击表示存在的这张卡被对方怪兽的攻击破坏送去墓地时，可以从自己卡组把2只植物族调整在自己场上表侧守备表示特殊召唤。
function c75252099.initial_effect(c)
	-- 场上表侧攻击表示存在的这张卡被对方怪兽的攻击破坏送去墓地时，可以从自己卡组把2只植物族调整在自己场上表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75252099,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c75252099.spcon)
	e1:SetTarget(c75252099.sptg)
	e1:SetOperation(c75252099.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡在自己场上表侧攻击表示存在，被对方怪兽攻击破坏并送去墓地。
function c75252099.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否在墓地、是否因战斗破坏、且是否为攻击目标。
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c==Duel.GetAttackTarget()
		and c:IsPreviousControler(tp) and c:GetBattlePosition()==POS_FACEUP_ATTACK
end
-- 过滤卡组中可以表侧守备表示特殊召唤的植物族调整怪兽。
function c75252099.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的可行性检测，包括青眼精灵龙的限制、怪兽区域空位以及卡组中是否存在2只符合条件的怪兽。
function c75252099.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域空位是否大于1个（即至少有2个空位）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己卡组中是否存在至少2只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c75252099.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置效果处理信息，声明该效果会从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择2只植物族调整怪兽在自己场上表侧守备表示特殊召唤。
function c75252099.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己场上的主要怪兽区域空位不足2个，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取自己卡组中所有满足条件的植物族调整怪兽组。
	local g=Duel.GetMatchingGroup(c75252099.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<2 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将选中的怪兽在自己场上表侧守备表示特殊召唤。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
