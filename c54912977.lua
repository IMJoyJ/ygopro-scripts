--マジック・ランプ
-- 效果：
-- ①：自己主要阶段才能发动。这张卡在场上表侧表示存在的场合，从手卡把1只「灯之魔精」特殊召唤。
-- ②：里侧守备表示的这张卡被对方怪兽攻击的伤害计算前，以攻击怪兽以外的1只对方怪兽为对象才能发动。攻击对象转移为那只对方怪兽进行伤害计算。
function c54912977.initial_effect(c)
	-- ②：里侧守备表示的这张卡被对方怪兽攻击的伤害计算前，以攻击怪兽以外的1只对方怪兽为对象才能发动。攻击对象转移为那只对方怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54912977,0))  --"攻击对象转移"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c54912977.condition)
	e1:SetTarget(c54912977.target)
	e1:SetOperation(c54912977.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡在场上表侧表示存在的场合，从手卡把1只「灯之魔精」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54912977,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c54912977.sptg)
	e2:SetOperation(c54912977.spop)
	c:RegisterEffect(e2)
end
-- 判定发动条件：此卡在里侧守备表示状态下被对方怪兽攻击，且处于伤害计算前。
function c54912977.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定不是代替效果、自身是被攻击对象且攻击怪兽是对方怪兽。
	return r~=REASON_REPLACE and Duel.GetAttackTarget()==e:GetHandler() and Duel.GetAttacker():IsControler(1-tp)
		and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
-- 效果2的靶向选择：检查并选择攻击怪兽以外的1只对方怪兽作为效果对象。
function c54912977.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查对方场上是否存在除攻击怪兽以外的怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,Duel.GetAttacker()) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只对方场上除攻击怪兽以外的怪兽作为对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,Duel.GetAttacker())
end
-- 效果2的处理：使攻击怪兽与选择的对象怪兽进行伤害计算。
function c54912977.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取当前的攻击怪兽。
	local a=Duel.GetAttacker()
	if tc and tc:IsRelateToEffect(e)
		and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		-- 令攻击怪兽与对象怪兽进行伤害计算。
		Duel.CalculateDamage(a,tc)
	end
end
-- 过滤手牌中可以特殊召唤的「灯之魔精」。
function c54912977.spfilter(c,e,tp)
	return c:IsCode(97590747) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的靶向选择：检查自己场上是否有空位以及手牌中是否有可特殊召唤的「灯之魔精」，并设置特殊召唤的操作信息。
function c54912977.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可以特殊召唤的「灯之魔精」。
		and Duel.IsExistingMatchingCard(c54912977.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手牌特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果1的处理：检查场地状态和自身状态，从手牌选择1只「灯之魔精」特殊召唤。
function c54912977.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域，若无则返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足条件的「灯之魔精」。
	local g=Duel.SelectMatchingCard(tp,c54912977.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
