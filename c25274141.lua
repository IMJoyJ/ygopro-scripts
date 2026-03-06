--緊急ダイヤ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。机械族·地属性的1只4星以下的怪兽和1只5星以上的怪兽从卡组效果无效守备表示特殊召唤。这张卡发动的回合，自己不用机械族怪兽不能攻击宣言。
-- ②：盖放的这张卡被送去墓地的场合才能发动。从卡组把1只机械族·10星怪兽加入手卡。
function c25274141.initial_effect(c)
	-- 效果原文内容：①：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。
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
	-- 效果原文内容：②：盖放的这张卡被送去墓地的场合才能发动。
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
	-- 规则层面操作：设置一个计数器，用于记录玩家在回合中攻击的次数
	Duel.AddCustomActivityCounter(25274141,ACTIVITY_ATTACK,c25274141.counterfilter)
end
-- 规则层面操作：计数器过滤函数，仅对机械族怪兽进行计数
function c25274141.counterfilter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 规则层面操作：判断对方场上的怪兽数量是否比自己场上的多
function c25274141.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断对方场上的怪兽数量是否比自己场上的多
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 规则层面操作：检查是否在本回合中已经发动过攻击宣言的限制效果
function c25274141.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否在本回合中已经发动过攻击宣言的限制效果
	if chk==0 then return Duel.GetCustomActivityCount(25274141,tp,ACTIVITY_ATTACK)==0 end
	-- 效果原文内容：机械族·地属性的1只4星以下的怪兽和1只5星以上的怪兽从卡组效果无效守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c25274141.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果注册给玩家，使其在场上生效
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面操作：设置攻击宣言限制的目标为非机械族怪兽
function c25274141.atktg(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 规则层面操作：过滤满足条件的4星以下机械族地属性怪兽
function c25274141.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面操作：过滤满足条件的5星以上机械族地属性怪兽
function c25274141.spfilter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面操作：检测是否满足特殊召唤条件，包括场地空位、青眼精灵龙效果、卡组中存在符合条件的怪兽
function c25274141.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面操作：检测卡组中是否存在满足条件的4星以下机械族地属性怪兽
		and Duel.IsExistingMatchingCard(c25274141.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 规则层面操作：检测卡组中是否存在满足条件的5星以上机械族地属性怪兽
		and Duel.IsExistingMatchingCard(c25274141.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 规则层面操作：设置连锁操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 规则层面操作：检测是否满足特殊召唤条件，包括青眼精灵龙效果、场地空位、卡组中存在符合条件的怪兽
function c25274141.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 规则层面操作：检测卡组中是否存在满足条件的4星以下机械族地属性怪兽
	if not Duel.IsExistingMatchingCard(c25274141.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 规则层面操作：检测卡组中是否存在满足条件的5星以上机械族地属性怪兽
		or not Duel.IsExistingMatchingCard(c25274141.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的4星以下机械族地属性怪兽
	local sg=Duel.SelectMatchingCard(tp,c25274141.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 规则层面操作：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的5星以上机械族地属性怪兽
	local sg2=Duel.SelectMatchingCard(tp,c25274141.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	sg:Merge(sg2)
	-- 规则层面操作：遍历已选择的怪兽组
	for tc in aux.Next(sg) do
		-- 规则层面操作：将怪兽特殊召唤到场上
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 效果原文内容：这张卡发动的回合，自己不用机械族怪兽不能攻击宣言。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果原文内容：这张卡发动的回合，自己不用机械族怪兽不能攻击宣言。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
	-- 规则层面操作：完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 规则层面操作：过滤满足条件的10星机械族怪兽
function c25274141.thfilter(c)
	return c:GetLevel()==10 and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 规则层面操作：判断此卡是否从场上盖放状态进入墓地
function c25274141.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 规则层面操作：检测是否满足检索条件
function c25274141.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检测是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c25274141.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁操作信息，表示将1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：处理检索效果的发动
function c25274141.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择满足条件的10星机械族怪兽
	local g=Duel.SelectMatchingCard(tp,c25274141.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 规则层面操作：将怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：确认对方查看了加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
