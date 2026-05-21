--疾風のドラグニティ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：只有对方场上才有怪兽存在的场合才能发动。从卡组把「龙骑兵团」调整和鸟兽族「龙骑兵团」怪兽各1只效果无效特殊召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，可以再只用自己场上的「龙骑兵团」怪兽为素材把1只龙族同调怪兽同调召唤。这张卡的发动后，直到回合结束时自己不是龙族怪兽不能从额外卡组特殊召唤。
function c89450409.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：只有对方场上才有怪兽存在的场合才能发动。从卡组把「龙骑兵团」调整和鸟兽族「龙骑兵团」怪兽各1只效果无效特殊召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，可以再只用自己场上的「龙骑兵团」怪兽为素材把1只龙族同调怪兽同调召唤。这张卡的发动后，直到回合结束时自己不是龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89450409,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,89450409+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c89450409.condition)
	e1:SetTarget(c89450409.target)
	e1:SetOperation(c89450409.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：只有对方场上才有怪兽存在
function c89450409.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤卡组中可以特殊召唤的「龙骑兵团」调整或鸟兽族「龙骑兵团」怪兽
function c89450409.filter(c,e,tp)
	return c:IsSetCard(0x29) and (c:IsType(TYPE_TUNER) or c:IsRace(RACE_WINDBEAST)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测与操作信息注册
function c89450409.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中符合条件的「龙骑兵团」怪兽
		local g=Duel.GetMatchingGroup(c89450409.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查卡组中是否存在可以特殊召唤的「龙骑兵团」调整和鸟兽族「龙骑兵团」怪兽各1只的组合
			and g:CheckSubGroup(aux.gffcheck,2,2,Card.IsType,TYPE_TUNER,Card.IsRace,RACE_WINDBEAST)
	end
	-- 设置在效果处理时从卡组特殊召唤2只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 过滤从额外卡组特殊召唤的怪兽
function c89450409.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤额外卡组中可以使用指定素材进行同调召唤的龙族同调怪兽
function c89450409.scfilter(c,mg)
	return c:IsRace(RACE_DRAGON) and c:IsSynchroSummonable(nil,mg)
end
-- 效果处理：适用额外特殊召唤限制，从卡组特殊召唤2只怪兽并无效其效果，满足条件时可进行同调召唤
function c89450409.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 从卡组把「龙骑兵团」调整和鸟兽族「龙骑兵团」怪兽各1只效果无效特殊召唤。这张卡的发动后，直到回合结束时自己不是龙族怪兽不能从额外卡组特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(c89450409.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制玩家从额外卡组特殊召唤非龙族怪兽的效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 在效果处理时获取卡组中符合条件的「龙骑兵团」怪兽
	local g=Duel.GetMatchingGroup(c89450409.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择「龙骑兵团」调整和鸟兽族「龙骑兵团」怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gffcheck,false,2,2,Card.IsType,TYPE_TUNER,Card.IsRace,RACE_WINDBEAST)
	if not sg then return end
	local ca=sg:GetFirst()
	local cb=sg:GetNext()
	local success=false
	-- 尝试将选中的2只怪兽以表侧表示特殊召唤
	if Duel.SpecialSummonStep(ca,0,tp,tp,false,false,POS_FACEUP) and Duel.SpecialSummonStep(cb,0,tp,tp,false,false,POS_FACEUP) then
		success=true
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ca:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ca:RegisterEffect(e2)
		local e3=e1:Clone()
		cb:RegisterEffect(e3)
		local e4=e2:Clone()
		cb:RegisterEffect(e4)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
	-- 获取自己场上作为同调素材的「龙骑兵团」怪兽
	local mg=Duel.GetSynchroMaterial(tp):Filter(Card.IsSetCard,nil,0x29)
	-- 检查特殊召唤是否成功，以及对方场上是否存在从额外卡组特殊召唤的怪兽
	if success and Duel.IsExistingMatchingCard(c89450409.cfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查额外卡组是否存在可同调召唤的龙族同调怪兽
		and Duel.IsExistingMatchingCard(c89450409.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
		-- 询问玩家是否进行同调召唤
		and Duel.SelectYesNo(tp,aux.Stringid(89450409,1)) then  --"是否进行同调召唤？"
		-- 提示玩家选择要同调召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择1只满足条件的龙族同调怪兽
		local tc=Duel.SelectMatchingCard(tp,c89450409.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg):GetFirst()
		-- 使用自己场上的「龙骑兵团」怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,tc,nil,mg)
	end
end
-- 限制玩家不能从额外卡组特殊召唤非龙族怪兽
function c89450409.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
