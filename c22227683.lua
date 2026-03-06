--ブンボーグ004
-- 效果：
-- ①：这张卡和对方怪兽进行战斗的伤害计算时才能发动。从卡组把「文具电子人004」以外的1只「文具电子人」怪兽送去墓地，这张卡的攻击力·守备力只在那次伤害计算时上升送去墓地的那只怪兽的等级×500。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
-- ②：这张卡战斗破坏对方怪兽的场合才能发动。从自己的手卡·墓地选2只等级不同的「文具电子人」怪兽守备表示特殊召唤。
function c22227683.initial_effect(c)
	-- 效果原文内容：①：这张卡和对方怪兽进行战斗的伤害计算时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c22227683.condition)
	e1:SetTarget(c22227683.target)
	e1:SetOperation(c22227683.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡战斗破坏对方怪兽的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 规则层面作用：设置效果的发动条件为与对方怪兽战斗时
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c22227683.sptg)
	e2:SetOperation(c22227683.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断当前是否处于与对方怪兽战斗的状态
function c22227683.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 规则层面作用：定义过滤条件，用于筛选「文具电子人」怪兽（除004外）
function c22227683.tgfilter(c)
	return c:IsSetCard(0xab) and c:IsType(TYPE_MONSTER) and not c:IsCode(22227683) and c:IsAbleToGrave()
end
-- 规则层面作用：设置效果的发动条件，检查卡组中是否存在满足条件的怪兽
function c22227683.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足发动条件，即卡组中存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22227683.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面作用：设置连锁操作信息，提示将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：处理效果发动时的主逻辑，包括选择并送去墓地的怪兽，以及提升攻击力和守备力
function c22227683.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c22227683.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 规则层面作用：判断所选怪兽是否成功送去墓地且当前怪兽处于战斗状态
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToBattle() and c:IsFaceup() then
		local lv=tc:GetLevel()
		-- 效果原文内容：这张卡的攻击力·守备力只在那次伤害计算时上升送去墓地的那只怪兽的等级×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	-- 效果原文内容：这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：注册一个持续到回合结束的战斗伤害无效效果
	Duel.RegisterEffect(e3,tp)
end
-- 规则层面作用：定义筛选条件，用于选择可特殊召唤的「文具电子人」怪兽（等级不同）
function c22227683.spfilter1(c,e,tp)
	return c:IsSetCard(0xab) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 规则层面作用：检查是否存在满足条件的第二只怪兽
		and Duel.IsExistingMatchingCard(c22227683.spfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c,e,tp,c:GetLevel())
end
-- 规则层面作用：定义筛选条件，用于选择等级不同的「文具电子人」怪兽
function c22227683.spfilter2(c,e,tp,lv)
	return c:IsSetCard(0xab) and c:IsType(TYPE_MONSTER) and not c:IsLevel(lv) and c:IsLevelAbove(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面作用：设置效果的发动条件，检查手卡或墓地中是否存在满足条件的怪兽
function c22227683.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面作用：检查玩家场上是否有足够的召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 规则层面作用：检查是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c22227683.spfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，提示将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 规则层面作用：处理效果发动时的主逻辑，包括选择并特殊召唤两只怪兽
function c22227683.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 规则层面作用：检查玩家场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从手卡或墓地中选择满足条件的第一只怪兽
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22227683.spfilter1),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		local tc=g1:GetFirst()
		-- 规则层面作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 规则层面作用：从手卡或墓地中选择满足条件的第二只怪兽
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22227683.spfilter2),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,tc,e,tp,tc:GetLevel())
		g1:Merge(g2)
		-- 规则层面作用：将选择的怪兽以守备表示形式特殊召唤到场上
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
