--バトル・スタン・ソニック
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。那次攻击无效。那之后，可以从手卡·卡组把1只「科技属」怪兽或者4星以下的调整特殊召唤。
function c93138457.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。那次攻击无效。那之后，可以从手卡·卡组把1只「科技属」怪兽或者4星以下的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c93138457.condition)
	e1:SetTarget(c93138457.target)
	e1:SetOperation(c93138457.activate)
	c:RegisterEffect(e1)
end
-- 发动条件检查，确认攻击宣言的怪兽是由对方控制的
function c93138457.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前进行攻击的怪兽控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数，检查是否为「科技属」怪兽或4星以下的调整且可特殊召唤
function c93138457.filter(c,e,tp)
	return (c:IsSetCard(0x27) or (c:IsLevelBelow(4) and c:IsType(TYPE_TUNER)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查，确认这张卡可以发动
function c93138457.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果处理，使对方的那次攻击无效，若成功无效且满足条件可从手卡·卡组特殊召唤1只「科技属」怪兽或4星以下的调整
function c93138457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡·卡组中所有可特殊召唤的「科技属」怪兽与4星以下调整
	local g=Duel.GetMatchingGroup(c93138457.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 无效本次攻击并检查是否成功无效、存在可特召怪兽且自己怪兽区有空位
	if Duel.NegateAttack() and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问控制者是否从手卡·卡组特殊召唤符合条件的怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(93138457,0)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤与前面的无效攻击视为不同时处理
		Duel.BreakEffect()
		-- 提示控制者从手卡·卡组选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「科技属」怪兽或4星以下调整表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
