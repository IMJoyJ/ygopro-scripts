--バトル・スタン・ソニック
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。那次攻击无效。那之后，可以从手卡·卡组把1只「科技属」怪兽或者4星以下的调整特殊召唤。
function c93138457.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。那次攻击无效。那之后，可以从手卡·卡组把1只「科技属」怪兽或者4星以下的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c93138457.condition)
	e1:SetTarget(c93138457.target)
	e1:SetOperation(c93138457.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：对方怪兽攻击宣言时
function c93138457.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数：筛选手卡或卡组中可以特殊召唤的「科技属」怪兽或者4星以下的调整怪兽
function c93138457.filter(c,e,tp)
	return (c:IsSetCard(0x27) or (c:IsLevelBelow(4) and c:IsType(TYPE_TUNER)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标处理函数（仅作发动检查，无对象）
function c93138457.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 定义效果处理函数：无效攻击，并可以从手卡·卡组特殊召唤符合条件的怪兽
function c93138457.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手卡和卡组中满足特殊召唤条件的怪兽卡组
	local g=Duel.GetMatchingGroup(c93138457.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 如果成功无效攻击，且手卡或卡组中存在可特召的怪兽，且己方主要怪兽区域有空位
	if Duel.NegateAttack() and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(93138457,0)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与无效攻击不视为同时进行
		Duel.BreakEffect()
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
