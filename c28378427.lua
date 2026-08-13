--ダメージ・コンデンサー
-- 效果：
-- 自己受到战斗伤害时，丢弃1张手卡才能发动。持有那个时候受到的伤害数值以下的攻击力的1只怪兽从卡组攻击表示特殊召唤。
function c28378427.initial_effect(c)
	-- 对应效果原文：“自己受到战斗伤害时，丢弃1张手卡才能发动。持有那个时候受到的伤害数值以下的攻击力的1只怪兽从卡组攻击表示特殊召唤。”本段是效果的整体创建与注册：生成一个效果对象，设置其为通常陷阱卡的发动型效果，并绑定战斗伤害触发条件、丢弃手卡的代价、发动时检查和效果处理函数，最后注册给这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c28378427.condition)
	e1:SetCost(c28378427.cost)
	e1:SetTarget(c28378427.target)
	e1:SetOperation(c28378427.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：判断受到战斗伤害的玩家是否为自己（ep==tp），即只有自己受到战斗伤害时才满足“自己受到战斗伤害时”的发动条件。
function c28378427.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 代价函数：发动前需要先选择并丢弃1张手卡，作为“丢弃1张手卡才能发动”的COST；同时确保有可丢弃的手卡才能发动。
function c28378427.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检测：chk==0时检查自己手牌中是否存在1张可以丢弃的手卡（且不能丢弃这张效果怪兽卡本身），若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从自己手牌中选择1张手卡丢弃（其中包含丢弃的COST原因），满足“丢弃1张手卡才能发动”的发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：从卡组中选出攻击力不高于所受到伤害数值（IsAttackBelow(dam)），并且能够以表侧攻击表示被特殊召唤的怪兽。
function c28378427.filter(c,e,tp,dam)
	return c:IsAttackBelow(dam) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时处理的目标检查：在发动时确认自己场上主要怪兽区有空位，且卡组中存在1只满足攻击力和特殊召唤条件的怪兽，否则不能发动。
function c28378427.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤的主要怪兽区空格（Duel.GetLocationCount(tp,LOCATION_MZONE)>0），确保后续特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只攻击力不高于伤害数值且能被特殊召唤的怪兽，作为能否发动“从卡组特殊召唤1只怪兽”的判定依据。
		and Duel.IsExistingMatchingCard(c28378427.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ev) end
	-- 设置操作信息：向系统声明本效果处理时将从卡组特殊召唤1只怪兽（不取对象，数量为1），用于满足星尘龙等对特殊召唤效果的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：在效果结算时，从卡组选择1只符合条件的怪兽，以表侧攻击表示特殊召唤到自己场上；若没有空格则直接结束处理。
function c28378427.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有主要怪兽区空格；若此时已没有空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家进行选择：弹出“请选择要特殊召唤的卡”的提示信息，并设定选择卡的用途为特殊召唤。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选择1张满足攻击力≤伤害数值且可攻击表示特殊召唤的怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c28378427.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if g:GetCount()~=0 then
		-- 将选中的怪兽特殊召唤到自己场上，表示形式为表侧攻击表示（POS_FACEUP_ATTACK），并忽略召唤条件与苏生限制的检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
