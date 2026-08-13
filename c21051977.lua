--コロボックリ
-- 效果：
-- 自己的主要阶段时才能发动。从手卡把1只「松果小矮人」送去墓地，这张卡从手卡特殊召唤。
function c21051977.initial_effect(c)
	-- 对应效果原文：自己的主要阶段时才能发动。从手卡把1只「松果小矮人」送去墓地，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21051977,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c21051977.sptg)
	e1:SetOperation(c21051977.spop)
	c:RegisterEffect(e1)
end
-- 定义发动条件的判定函数：在效果发动时（chk==0）确认自己场上有空余的怪兽区、手牌中存在「松果小矮人」、且这张卡本身可以被特殊召唤，全部满足才允许发动。
function c21051977.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区，确保特殊召唤时有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在1张卡名为「松果小矮人」（卡号67445676）的卡，作为效果处理时送去墓地的对象。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,67445676)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 登记本次连锁的操作信息：本效果包含特殊召唤，对象为这张卡自身，数量为1，供后续时点及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：提示玩家选择手牌中的「松果小矮人」，将其送去墓地，随后若这张卡仍与效果关联则将其表侧表示特殊召唤到自己的主要怪兽区。
function c21051977.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择一张要送去墓地的卡（提示文本为“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手牌中筛选并选择1张「松果小矮人」（卡号67445676）作为本次效果处理的对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,67445676)
	if g:GetCount()==0 then return end
	-- 将选中的「松果小矮人」从手牌以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡「小矮人橡子」以表侧表示特殊召唤到自己的主要怪兽区，完成特殊召唤。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
