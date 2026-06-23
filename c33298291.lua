--獣湧き肉躍り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方怪兽的直接攻击宣言时，对方场上的表侧表示怪兽的攻击力合计是8000以上的场合才能发动。把3只原本卡名不同的怪兽从自己的手卡·卡组·墓地各选1只攻击表示特殊召唤。
function c33298291.initial_effect(c)
	-- 效果设置：发动时点为攻击宣言，分类为特殊召唤，发动次数限制为1次，条件为对方怪兽直接攻击且对方场上表侧表示怪兽攻击力合计≥8000
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,33298291+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c33298291.condition)
	e1:SetTarget(c33298291.target)
	e1:SetOperation(c33298291.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：对方怪兽进行直接攻击且对方场上表侧表示怪兽攻击力合计≥8000
function c33298291.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetAttack)
	-- 判断是否为对方怪兽的直接攻击且对方没有攻击目标且对方场上表侧表示怪兽攻击力合计≥8000
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and atk>=8000
end
-- 特殊召唤过滤函数：检查怪兽是否可以被特殊召唤（不检查召唤条件，不检查苏生限制，攻击表示）
function c33298291.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 检查组中是否存在与当前怪兽原卡名相同的怪兽
function c33298291.fcheck(c,g)
	return g:IsExists(Card.IsOriginalCodeRule,1,c,c:GetOriginalCodeRule())
end
-- 选择组中满足条件的怪兽：位置不同且原卡名不同的怪兽组合
function c33298291.fselect(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and not g:IsExists(c33298291.fcheck,1,nil,g)
end
-- 效果目标：检索满足条件的怪兽组并检查是否能选出3只不同原卡名的怪兽
function c33298291.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足特殊召唤条件的怪兽（手牌、卡组、墓地）
	local g=Duel.GetMatchingGroup(c33298291.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return g:CheckSubGroup(c33298291.fselect,3,3) end
	-- 设置操作信息：准备特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动：检查是否满足特殊召唤条件并执行特殊召唤
function c33298291.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检索满足特殊召唤条件且不受王家长眠之谷影响的怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33298291.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c33298291.fselect,false,3,3)
	if sg and sg:GetCount()==3 then
		-- 将选中的怪兽以攻击表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
