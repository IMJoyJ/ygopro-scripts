--緊急ダイヤ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。机械族·地属性的1只4星以下的怪兽和1只5星以上的怪兽从卡组效果无效守备表示特殊召唤。这张卡发动的回合，自己不用机械族怪兽不能攻击宣言。
-- ②：盖放的这张卡被送去墓地的场合才能发动。从卡组把1只机械族·10星怪兽加入手卡。
function c25274141.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。机械族·地属性的1只4星以下的怪兽和1只5星以上的怪兽从卡组效果无效守备表示特殊召唤。这张卡发动的回合，自己不用机械族怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25274141,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25274141)
	e1:SetCondition(c25274141.spcon)
	e1:SetCost(c25274141.spcost)
	e1:SetTarget(c25274141.sptg)
	e1:SetOperation(c25274141.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：盖放的这张卡被送去墓地的场合才能发动。从卡组把1只机械族·10星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25274141,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,25274142)
	e2:SetCondition(c25274141.thcon)
	e2:SetTarget(c25274141.thtg)
	e2:SetOperation(c25274141.thop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器（代号25274141，攻击宣言类型），用于记录本回合玩家进行过的非机械族怪兽攻击宣言次数，供①效果的发动前检查和发动后的攻击限制使用。
	Duel.AddCustomActivityCounter(25274141,ACTIVITY_ATTACK,c25274141.counterfilter)
end
-- 活动计数器的过滤函数：若怪兽是机械族则返回true（不计入违规攻击）；非机械族返回false，攻击宣言时计数器加1，用于检测玩家是否已经用非机械族怪兽攻击过。
function c25274141.counterfilter(c)
	return c:IsRace(RACE_MACHINE)
end
-- ①效果的发动条件判断：对方场上的怪兽数量是否比自己场上的怪兽数量多。
function c25274141.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方和自己场上怪兽区域怪兽的数量：对方MZONE数量 > 自己MZONE数量。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- ①效果的发动代价处理：确认本回合尚未用非机械族怪兽攻击宣言；然后给自己场上所有非机械族怪兽附加“不能攻击宣言”的誓约效果，持续到回合结束。
function c25274141.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：通过自定义计数器确认本回合非机械族怪兽攻击宣言次数为0，否则不能发动。
	if chk==0 then return Duel.GetCustomActivityCount(25274141,tp,ACTIVITY_ATTACK)==0 end
	-- 机械族·地属性的1只4星以下的怪兽和1只5星以上的怪兽从卡组效果无效守备表示特殊召唤。这张卡发动的回合，自己不用机械族怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c25274141.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新建的不能攻击宣言效果注册到场上并生效：本回合自己场上非机械族怪兽不能进行攻击宣言。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制的过滤条件：返回true表示该怪兽被禁止攻击，即非机械族怪兽。
function c25274141.atktg(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 第1个特殊召唤过滤函数：从卡组选择机械族、地属性、4星以下、可以表侧守备表示特殊召唤的怪兽。
function c25274141.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 第2个特殊召唤过滤函数：从卡组选择机械族、地属性、5星以上、可以表侧守备表示特殊召唤的怪兽。
function c25274141.spfilter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果发动时的目标检查：自己场上可用怪兽区>1、没有受到青眼精灵龙“禁止同时特殊召唤2只以上怪兽”的效果影响、且卡组中存在满足条件的4星以下和5星以上的机械族·地属性怪兽各1只。
function c25274141.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查卡组中是否存在至少1只满足spfilter1（4星以下机械族·地属性）的怪兽。
		and Duel.IsExistingMatchingCard(c25274141.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查卡组中是否存在至少1只满足spfilter2（5星以上机械族·地属性）的怪兽。
		and Duel.IsExistingMatchingCard(c25274141.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 登记操作信息：本次效果处理将从卡组特殊召唤2只怪兽，供其他卡/效果进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ①效果处理函数：处理开始时再次确认青眼精灵龙效果不适用、自己场上仍有至少2个可用怪兽区、且卡组中两类怪兽仍存在，否则直接终止处理。
function c25274141.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 若卡组中已不存在满足spfilter1的怪兽，则本次特殊召唤处理直接返回。
	if not Duel.IsExistingMatchingCard(c25274141.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 若卡组中已不存在满足spfilter2的怪兽，则本次特殊召唤处理直接返回。
		or not Duel.IsExistingMatchingCard(c25274141.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) then return end
	-- 弹出选择提示“请选择要特殊召唤的卡”，用于选择第1只（4星以下）怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足spfilter1的怪兽，作为第1只特殊召唤对象。
	local sg=Duel.SelectMatchingCard(tp,c25274141.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 弹出选择提示“请选择要特殊召唤的卡”，用于选择第2只（5星以上）怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足spfilter2的怪兽，作为第2只特殊召唤对象。
	local sg2=Duel.SelectMatchingCard(tp,c25274141.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	sg:Merge(sg2)
	-- 遍历已选择的两只怪兽，逐只进行特殊召唤及效果无效化处理。
	for tc in aux.Next(sg) do
		-- 将当前怪兽以表侧守备表示特殊召唤（不检查召唤条件/苏生限制）；成功后才继续附加效果无效化。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 从卡组效果无效守备表示特殊召唤。——“效果无效”部分：为特殊召唤成功的怪兽附加效果无效状态。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 从卡组效果无效守备表示特殊召唤。——“效果无效”部分：为特殊召唤成功的怪兽附加效果无效化状态，使效果不能发动/适用。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
	-- 结束特殊召唤步骤，正式完成所有怪兽的特殊召唤，并触发召唤成功相关时点。
	Duel.SpecialSummonComplete()
end
-- ②效果检索过滤函数：筛选卡组中机械族、10星、可以加入手卡的怪兽。
function c25274141.thfilter(c)
	return c:GetLevel()==10 and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- ②效果发动条件：这张卡被送去墓地前位于场上，且为里侧表示（盖放），即“盖放的这张卡被送去墓地的场合”。
function c25274141.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- ②效果的目标检查：卡组中存在机械族10星怪兽时，登记操作信息表示将从卡组把1张机械族10星怪兽加入手卡。
function c25274141.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1只满足thfilter的机械族10星怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25274141.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理将从卡组把1张卡加入手卡，供其他卡/效果进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只机械族10星怪兽加入手卡，并让对方确认加入手卡的卡。
function c25274141.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足thfilter的机械族10星怪兽。
	local g=Duel.SelectMatchingCard(tp,c25274141.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
