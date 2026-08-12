--リバイバル・ギフト
-- 效果：
-- 选择自己墓地存在的1只调整特殊召唤。这个效果特殊召唤的怪兽的效果无效化。在对方场上把2只「礼物魔衍生物」（恶魔族·暗·3星·攻/守1500）特殊召唤。
function c93912845.initial_effect(c)
	-- 选择自己墓地存在的1只调整特殊召唤。这个效果特殊召唤的怪兽的效果无效化。在对方场上把2只「礼物魔衍生物」（恶魔族·暗·3星·攻/守1500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c93912845.target)
	e1:SetOperation(c93912845.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以特殊召唤的调整怪兽
function c93912845.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检测
function c93912845.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93912845.spfilter(chkc,e,tp) end
	-- 检查双方场上是否有足够的空怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己墓地是否存在可以特殊召唤的调整怪兽
		and Duel.IsExistingTarget(c93912845.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查是否能在对方场上特殊召唤「礼物魔衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93912846,0,TYPES_TOKEN_MONSTER,1500,1500,3,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,1-tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93912845.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置在对方场上特殊召唤2只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置特殊召唤目标调整怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c93912845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取作为效果对象的调整怪兽
		local tc=Duel.GetFirstTarget()
		-- 若目标怪兽仍符合效果条件，则将其特殊召唤到自己场上
		if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 这个效果特殊召唤的怪兽的效果无效化。在对方场上把2只「礼物魔衍生物」（恶魔族·暗·3星·攻/守1500）特殊召唤。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end
	-- 检查对方场上是否有2个以上的空怪兽区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>1
		-- 检查是否能在对方场上特殊召唤「礼物魔衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93912846,0,TYPES_TOKEN_MONSTER,1500,1500,3,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,1-tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		for i=1,2 do
			-- 创建「礼物魔衍生物」卡片数据
			local token=Duel.CreateToken(tp,93912846)
			-- 将衍生物特殊召唤到对方场上
			Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
