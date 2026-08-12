--超重武者ジシャ－Q
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「超重武者」怪兽特殊召唤。那之后，这张卡变成守备表示。
-- ②：只要这张卡在怪兽区域存在，对方不能向其他怪兽攻击。
function c89091772.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「超重武者」怪兽特殊召唤。那之后，这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89091772,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c89091772.sumtg)
	e1:SetOperation(c89091772.sumop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能向其他怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c89091772.atlimit)
	c:RegisterEffect(e2)
end
-- 过滤手卡中4星以下的「超重武者」怪兽
function c89091772.filter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与可行性检查
function c89091772.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c89091772.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理，包含特殊召唤和改变表示形式
function c89091772.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c89091772.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 将选中的怪兽以表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 中断当前效果，使后续的改变表示形式处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 将这张卡变成表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 限制对方不能选择除这张卡以外的怪兽作为攻击对象
function c89091772.atlimit(e,c)
	return c~=e:GetHandler()
end
