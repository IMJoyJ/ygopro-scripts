--パーリィナイツ
-- 效果：
-- ①：对方怪兽的攻击让自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。那之后，可以把持有受到的伤害数值以下的攻击力的1只怪兽从手卡特殊召唤。
function c17988746.initial_effect(c)
	-- 创建一个诱发选发效果，满足条件时可以将此卡从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17988746,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c17988746.condition)
	e1:SetTarget(c17988746.target)
	e1:SetOperation(c17988746.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：对方怪兽的攻击让自己受到战斗伤害时
function c17988746.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方受到战斗伤害的玩家是自己，且攻击怪兽的控制者是对方
	return ep==tp and 1-tp==rp and Duel.GetAttacker():IsControler(1-tp)
end
-- 效果目标：检查自己是否可以将此卡特殊召唤
function c17988746.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空位以及此卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数：筛选手卡中攻击力不超过指定值且可以特殊召唤的怪兽
function c17988746.filter(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：将此卡特殊召唤，然后选择是否特殊召唤手卡中符合条件的怪兽
function c17988746.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到自己场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检索手卡中攻击力不超过受到伤害值且可以特殊召唤的怪兽
		local g=Duel.GetMatchingGroup(c17988746.filter,tp,LOCATION_HAND,0,nil,e,tp,ev)
		-- 检查自己场上是否有空位且检索到的怪兽数量大于0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
			-- 询问玩家是否发动特殊召唤手卡怪兽的效果
			and Duel.SelectYesNo(tp,aux.Stringid(17988746,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
