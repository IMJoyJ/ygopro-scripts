--パーリィナイツ
-- 效果：
-- ①：对方怪兽的攻击让自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。那之后，可以把持有受到的伤害数值以下的攻击力的1只怪兽从手卡特殊召唤。
function c17988746.initial_effect(c)
	-- ①：对方怪兽的攻击让自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。那之后，可以把持有受到的伤害数值以下的攻击力的1只怪兽从手卡特殊召唤。
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
-- 定义效果触发条件函数：判定战斗伤害是否满足“对方怪兽的攻击让自己受到战斗伤害”这一前提。
function c17988746.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认受到战斗伤害的是本卡持有者（ep==tp）、造成伤害的是对方玩家（1-tp==rp），且攻击怪兽由对方控制（Duel.GetAttacker():IsControler(1-tp)）。
	return ep==tp and 1-tp==rp and Duel.GetAttacker():IsControler(1-tp)
end
-- 定义效果发动时的合法目标与条件检查函数：检查自己场上怪兽区是否有空位，以及手卡中的这张卡是否可以被特殊召唤。
function c17988746.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk==0（效果发动合法性检查）时，确认自己场上主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将进行的操作信息：预定特殊召唤这张卡（对象为c，数量1），供后续发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义追加特殊召唤的筛选函数：选择手牌中攻击力不高于所受战斗伤害数值、且当前可以被特殊召唤的怪兽。
function c17988746.filter(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果解决时的处理流程：先特殊召唤这张卡，成功后再从手牌选择符合条件的怪兽进行追加特殊召唤。
function c17988746.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以表侧攻击表示特殊召唤到自己场上，并判断是否特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己手牌中满足c17988746.filter条件的所有怪兽集合（攻击力≤所受伤害且可特殊召唤）。
		local g=Duel.GetMatchingGroup(c17988746.filter,tp,LOCATION_HAND,0,nil,e,tp,ev)
		-- 检查追加处理是否仍可行：自己场上还有空位，且存在可选怪兽。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
			-- 向玩家询问是否发动“那之后”的追加特殊召唤处理。
			and Duel.SelectYesNo(tp,aux.Stringid(17988746,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的追加特殊召唤作为独立效果处理执行，防止因同一时点处理导致错失时点。
			Duel.BreakEffect()
			-- 给出“请选择要特殊召唤的卡”的提示信息，让玩家从候选集合中选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选择的怪兽从手卡以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
