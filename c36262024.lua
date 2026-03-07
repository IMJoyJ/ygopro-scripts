--黒竜の雛
-- 效果：
-- 把自己场上表侧表示存在的这张卡送去墓地才能发动。从手卡把1只「真红眼黑龙」特殊召唤。
function c36262024.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的这张卡送去墓地才能发动。从手卡把1只「真红眼黑龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36262024,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c36262024.spcost)
	e1:SetTarget(c36262024.sptg)
	e1:SetOperation(c36262024.spop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否可以支付将自身送去墓地的代价
function c36262024.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面操作：将自身送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面操作：定义用于筛选「真红眼黑龙」的过滤函数
function c36262024.filter(c,e,tp)
	return c:IsCode(74677422) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足发动条件，即手卡存在「真红眼黑龙」且场上存在召唤空间
function c36262024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查场上是否有召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 规则层面操作：检查手卡是否存在满足条件的「真红眼黑龙」
		and Duel.IsExistingMatchingCard(c36262024.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁处理信息，表明本次效果将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面操作：处理效果发动后的特殊召唤流程
function c36262024.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场上是否还有召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从手卡选择1只「真红眼黑龙」作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c36262024.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
