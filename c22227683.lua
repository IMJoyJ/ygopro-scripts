--ブンボーグ004
-- 效果：
-- ①：这张卡和对方怪兽进行战斗的伤害计算时才能发动。从卡组把「文具电子人004」以外的1只「文具电子人」怪兽送去墓地，这张卡的攻击力·守备力只在那次伤害计算时上升送去墓地的那只怪兽的等级×500。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
-- ②：这张卡战斗破坏对方怪兽的场合才能发动。从自己的手卡·墓地选2只等级不同的「文具电子人」怪兽守备表示特殊召唤。
function c22227683.initial_effect(c)
	-- ①：这张卡和对方怪兽进行战斗的伤害计算时才能发动。从卡组把「文具电子人004」以外的1只「文具电子人」怪兽送去墓地，这张卡的攻击力·守备力只在那次伤害计算时上升送去墓地的那只怪兽的等级×500。这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。
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
	-- ②：这张卡战斗破坏对方怪兽的场合才能发动。从自己的手卡·墓地选2只等级不同的「文具电子人」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置②效果的发动条件：此卡与本次战斗有关且对方怪兽被战斗破坏（即战斗破坏对方怪兽的场合）。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c22227683.sptg)
	e2:SetOperation(c22227683.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：此卡拥有战斗对象（正在进行伤害计算的对方怪兽），即与对方怪兽进行战斗的伤害计算时。
function c22227683.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 效果①的选卡过滤器：从卡组中选出满足「文具电子人」字段、是怪兽卡、卡名不是「文具电子人004」且可以送去墓地的卡。
function c22227683.tgfilter(c)
	return c:IsSetCard(0xab) and c:IsType(TYPE_MONSTER) and not c:IsCode(22227683) and c:IsAbleToGrave()
end
-- 效果①的发动目标判定与操作信息预设定：检查能否从卡组将1只符合条件的「文具电子人」怪兽送去墓地，并预声明本次连锁存在CATEGORY_TOGRAVE处理。
function c22227683.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中存在至少1张满足tgfilter条件的「文具电子人」怪兽，作为①效果可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c22227683.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次连锁的操作信息设定为：把1张卡从发动者卡组送去墓地，供后续效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的解决处理：从卡组选择1只符合条件的「文具电子人」怪兽送去墓地；送去成功且此卡仍与战斗相关、表侧表示时，根据那只怪兽的等级，让此卡的攻击力·守备力在本次伤害计算期间上升等级×500。
function c22227683.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向操作者显示“请选择要送去墓地的卡”的提示，用于选择卡组中的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足tgfilter条件的「文具电子人」怪兽（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c22227683.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡送去墓地，并确认送入墓地成功且该卡在墓地中，同时此卡仍与战斗相关且表侧表示，才继续执行攻击力·守备力上升。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToBattle() and c:IsFaceup() then
		local lv=tc:GetLevel()
		-- 这张卡的攻击力·守备力只在那次伤害计算时上升送去墓地的那只怪兽的等级×500。
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
	-- 这个效果的发动后，直到回合结束时对方受到的战斗伤害变成0。②：这张卡战斗破坏对方怪兽的场合才能发动。从自己的手卡·墓地选2只等级不同的「文具电子人」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方玩家受到的战斗伤害变成0”的永续效果注册到场上，持续到结束阶段。
	Duel.RegisterEffect(e3,tp)
end
-- 效果②第一只怪兽的过滤器：从手卡/墓地中选出满足「文具电子人」字段、是怪兽卡、可以以表侧守备表示特殊召唤，且能再选出一只等级不同的「文具电子人」怪兽作为第二只的卡。
function c22227683.spfilter1(c,e,tp)
	return c:IsSetCard(0xab) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 作为spfilter1的附加条件：确认手卡/墓地中存在至少1只与候选怪兽等级不同且满足spfilter2的「文具电子人」怪兽，以保证能凑出2只等级不同的怪兽。
		and Duel.IsExistingMatchingCard(c22227683.spfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c,e,tp,c:GetLevel())
end
-- 效果②第二只怪兽的过滤器：从手卡/墓地中选出满足「文具电子人」字段、是怪兽卡、等级不低于1且与第一只怪兽等级不同，并能以表侧守备表示特殊召唤的卡。
function c22227683.spfilter2(c,e,tp,lv)
	return c:IsSetCard(0xab) and c:IsType(TYPE_MONSTER) and not c:IsLevel(lv) and c:IsLevelAbove(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动条件检查：确认没有青眼精灵龙的效果禁止同时特殊召唤2只以上怪兽、自己场上可用的怪兽区域足够，且手卡/墓地中存在可特殊召唤的2只等级不同的「文具电子人」怪兽。
function c22227683.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己场上拥有2个或以上的可用怪兽区域，以满足同时特殊召唤2只怪兽所需的空间。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认手卡/墓地中至少存在1只可通过spfilter1选定、并能联动选出第二只等级不同的「文具电子人」怪兽的候选，作为发动②的前提条件。
		and Duel.IsExistingMatchingCard(c22227683.spfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息设定为：从手卡·墓地特殊召唤2只怪兽，供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果②的解决处理：再次确认青眼精灵龙效果不适用且自己怪兽区域充足；从手卡/墓地选第一只符合条件的「文具电子人」怪兽，再选第二只等级不同的「文具电子人」怪兽，将2只怪兽以表侧守备表示特殊召唤。
function c22227683.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时若自己场上可用怪兽区域不足2个，则终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示，用于选择第一只特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只满足spfilter1条件的「文具电子人」怪兽作为第一只特殊召唤对象。
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22227683.spfilter1),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		local tc=g1:GetFirst()
		-- 向操作者显示“请选择要特殊召唤的卡”的提示，用于选择第二只特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只满足spfilter2条件、且等级与第一只不同的「文具电子人」怪兽作为第二只特殊召唤对象。
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22227683.spfilter2),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,tc,e,tp,tc:GetLevel())
		g1:Merge(g2)
		-- 将选出的2只「文具电子人」怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
