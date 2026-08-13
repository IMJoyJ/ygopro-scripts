--獣湧き肉躍り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方怪兽的直接攻击宣言时，对方场上的表侧表示怪兽的攻击力合计是8000以上的场合才能发动。把3只原本卡名不同的怪兽从自己的手卡·卡组·墓地各选1只攻击表示特殊召唤。
function c33298291.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方怪兽的直接攻击宣言时，对方场上的表侧表示怪兽的攻击力合计是8000以上的场合才能发动。把3只原本卡名不同的怪兽从自己的手卡·卡组·墓地各选1只攻击表示特殊召唤。
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
-- 判定是否满足发动条件：对方怪兽进行直接攻击宣言，且对方场上表侧表示怪兽的攻击力合计不少于8000；具体为获取对方场上所有表侧表示怪兽，计算其攻击力合计，并确认攻击者是对方怪兽且攻击目标为空。
function c33298291.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetAttack)
	-- 满足发动条件的三项判断：攻击者为对方怪兽、攻击目标为空（即直接攻击）、对方场上表侧表示怪兽的攻击力合计不低于8000。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and atk>=8000
end
-- spfilter过滤函数：判断一只怪兽是否可以被玩家tp通过效果e以表侧攻击表示特殊召唤（不忽略召唤条件和苏生限制）。
function c33298291.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- fcheck过滤函数：在集合g中查找除当前卡c外，是否存在规则原本卡号与c相同的另一张卡，用于排除原本卡名重复的组合。
function c33298291.fcheck(c,g)
	return g:IsExists(Card.IsOriginalCodeRule,1,c,c:GetOriginalCodeRule())
end
-- fselect选择验证函数：所选集合g满足3张卡来自3个不同区域（手卡/卡组/墓地各1张），且任意两张卡原本卡名均不相同。
function c33298291.fselect(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and not g:IsExists(c33298291.fcheck,1,nil,g)
end
-- target函数：效果发动时从手卡·卡组·墓地中检查是否存在可特殊召唤且满足‘来自3个不同区域且原本卡名互不相同’的3张卡；若存在则判定可以发动，并设置特殊召唤的操作信息。
function c33298291.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡、卡组、墓地中所有满足spfilter条件（可被特殊召唤）的怪兽集合，作为后续选择的候选。
	local g=Duel.GetMatchingGroup(c33298291.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return g:CheckSubGroup(c33298291.fselect,3,3) end
	-- 设置当前连锁的操作信息：本效果将进行特殊召唤，预定处理3只怪兽，来源为自己手卡·卡组·墓地；因具体对象在效果处理时才确定，目标组设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：先检查自己场上怪兽区域是否存在至少3个可用格子，且自己未受‘青眼精灵龙’效果影响（该效果禁止双方同时特殊召唤2只以上怪兽）；若不满足则直接终止。随后从手卡·卡组·墓地选择符合条件（来自3个不同区域且原本卡名互不相同）的3只怪兽，以表侧攻击表示特殊召唤。
function c33298291.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取手卡·卡组·墓地中可特殊召唤且不受‘王家长眠之谷’影响的怪兽集合（通过NecroValleyFilter排除因王谷效果无法从墓地特殊召唤的卡）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33298291.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 给玩家tp显示选择提示消息，提示文字为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c33298291.fselect,false,3,3)
	if sg and sg:GetCount()==3 then
		-- 将选中的3只怪兽以表侧攻击表示特殊召唤到玩家tp的场上（sumtype为0，且不忽略召唤条件和苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
