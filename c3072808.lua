--BF－天狗風のヒレン
-- 效果：
-- 这张卡在墓地存在，对方怪兽的直接攻击让自己受到2000以上的战斗伤害时，选择自己墓地存在的1只名字带有「黑羽」的3星以下的怪兽发动。选择的怪兽和这张卡从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「黑羽-天狗风之飞廉」的效果在决斗中只能使用1次。
function c3072808.initial_effect(c)
	-- 这张卡在墓地存在，对方怪兽的直接攻击让自己受到2000以上的战斗伤害时，选择自己墓地存在的1只名字带有「黑羽」的3星以下的怪兽发动。选择的怪兽和这张卡从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「黑羽-天狗风之飞廉」的效果在决斗中只能使用1次。
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
-- 定义发动条件的判定函数：本效果仅在己方受到对方怪兽直接攻击造成的2000点以上战斗伤害时才能发动，即伤害对象是己方、伤害数值不低于2000、且该攻击没有攻击目标（直接攻击）。
function c3072808.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：受到的战斗伤害方为己方（ep==tp）、伤害数值不低于2000、且该次攻击为直接攻击（Duel.GetAttackTarget()==nil表示没有攻击对象）。
	return ep==tp and ev>=2000 and Duel.GetAttackTarget()==nil
end
-- 定义可特殊召唤的墓地怪兽的筛选函数：要求是等级3以下、卡名带有「黑羽」字段、且能够被当前效果特殊召唤的怪兽。
function c3072808.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：先从自己墓地选择1只满足条件的「黑羽」3星以下怪兽作为对象（选择时排除本卡自身），再把本卡自身加入对象组，最后设置将2只怪兽特殊召唤的操作信息。
function c3072808.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3072808.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 给玩家显示选择提示：请选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合c3072808.filter条件的「黑羽」3星以下怪兽作为效果对象，e:GetHandler()即本卡自身被排除，不能选择自身；同时该对象与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,c3072808.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	g:AddCard(e:GetHandler())
	-- 将本次操作信息登记为“特殊召唤2只怪兽”，目标组为选中的对象加上本卡自身，供连锁判定与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：先检查场上是否存在「青眼精灵龙」的‘不能同时特殊召唤2只以上怪兽’限制，以及己方怪兽区域是否有至少2个空格；确认本卡与选中的对象仍与效果关联且可特殊召唤后，为两只怪兽附加效果无效化状态，最后把两只怪兽连续特殊召唤。
function c3072808.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 取得效果处理时的第一个对象卡，即发动时选择的墓地「黑羽」3星以下怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查己方主要怪兽区域是否有至少2个可用的空格；若不足2个则无法同时特殊召唤2只怪兽，效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 这个效果特殊召唤的怪兽的效果无效化。
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
	-- 将本卡（黑羽-天狗风之飞廉）以表侧攻击表示特殊召唤到己方怪兽区域（作为连续特殊召唤的第一步，暂不生效）。
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	-- 将选择的那只墓地「黑羽」3星以下怪兽以表侧攻击表示特殊召唤到己方怪兽区域（作为连续特殊召唤的第二步）。
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	-- 完成本次一连串的特殊召唤处理，使上述两只怪兽的特殊召唤正式成功。
	Duel.SpecialSummonComplete()
end
