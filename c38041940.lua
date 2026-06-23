--シード・オブ・フレイム
-- 效果：
-- 自己场上存在的这张卡被卡的效果破坏送去墓地时才能发动。自己墓地存在的「火焰花种」以外的1只4星以下的植物族怪兽在自己场上特殊召唤，在对方场上把1只「花种衍生物」（植物族·地·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c38041940.initial_effect(c)
	-- 自己场上存在的这张卡被卡的效果破坏送去墓地时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38041940,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c38041940.condition)
	e1:SetTarget(c38041940.target)
	e1:SetOperation(c38041940.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：卡片被破坏送入墓地且之前在场上控制者为玩家
function c38041940.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp)
end
-- 筛选墓地中的植物族4星以下且非火焰花种的怪兽
function c38041940.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and not c:IsCode(38041940) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：己方和对方场上都有空位，且未被青眼精灵龙效果影响，且存在符合条件的怪兽，且可以特殊召唤衍生物
function c38041940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38041940.spfilter(chkc,e,tp) end
	-- 检测己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测己方墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c38041940.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检测玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38041941,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c38041940.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 处理效果：特殊召唤目标怪兽并召唤衍生物
function c38041940.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且种族为植物族并开始特殊召唤流程
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 检测对方场上是否有空位
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检测玩家是否可以特殊召唤衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,38041941,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then
			-- 创建衍生物
			local token=Duel.CreateToken(tp,38041941)
			-- 特殊召唤衍生物
			Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			-- 衍生物不能为上级召唤而解放
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
