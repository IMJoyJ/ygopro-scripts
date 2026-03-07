--BF－天狗風のヒレン
-- 效果：
-- 这张卡在墓地存在，对方怪兽的直接攻击让自己受到2000以上的战斗伤害时，选择自己墓地存在的1只名字带有「黑羽」的3星以下的怪兽发动。选择的怪兽和这张卡从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「黑羽-天狗风之飞廉」的效果在决斗中只能使用1次。
function c3072808.initial_effect(c)
	-- 效果原文：这张卡在墓地存在，对方怪兽的直接攻击让自己受到2000以上的战斗伤害时，选择自己墓地存在的1只名字带有「黑羽」的3星以下的怪兽发动。选择的怪兽和这张卡从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「黑羽-天狗风之飞廉」的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3072808,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,3072808+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c3072808.condition)
	e1:SetTarget(c3072808.target)
	e1:SetOperation(c3072808.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件，即对方怪兽直接攻击造成自身2000以上战斗伤害且未被阻挡
function c3072808.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：对方怪兽的直接攻击让自己受到2000以上的战斗伤害时
	return ep==tp and ev>=2000 and Duel.GetAttackTarget()==nil
end
-- 效果作用：定义可选择的墓地怪兽过滤条件，即等级3以下且属于黑羽卡组
function c3072808.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置选择目标阶段，选择一只符合条件的墓地怪兽和自身作为特殊召唤对象
function c3072808.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3072808.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 效果作用：向玩家提示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从玩家墓地中选择符合条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c3072808.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	g:AddCard(e:GetHandler())
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果作用：执行特殊召唤及效果无效化处理
function c3072808.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 效果作用：检查玩家场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 效果原文：这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	tc:RegisterEffect(e3)
	local e4=e2:Clone()
	tc:RegisterEffect(e4)
	-- 效果作用：将自身特殊召唤到场上
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	-- 效果作用：将选择的墓地怪兽特殊召唤到场上
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 效果作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
