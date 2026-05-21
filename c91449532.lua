--EMオールカバー・ヒッポ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只「娱乐伙伴」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
-- ②：1回合1次，自己主要阶段才能发动。自己场上的怪兽全部变成守备表示。
function c91449532.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只「娱乐伙伴」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91449532,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c91449532.sptg)
	e1:SetOperation(c91449532.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己场上的怪兽全部变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91449532,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c91449532.postg)
	e2:SetOperation(c91449532.posop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可以特殊召唤的「娱乐伙伴」怪兽
function c91449532.spfilter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空位以及手牌中是否存在可特殊召唤的「娱乐伙伴」怪兽，并设置特殊召唤的操作信息）
function c91449532.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足过滤条件的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c91449532.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（从手牌特殊召唤1只「娱乐伙伴」怪兽，并将其效果直到回合结束时无效化）
function c91449532.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足过滤条件的「娱乐伙伴」怪兽
	local g=Duel.SelectMatchingCard(tp,c91449532.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择卡片，则尝试将其以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 过滤自己场上处于攻击表示且可以改变表示形式的怪兽
function c91449532.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果②的发动准备（检查自己场上是否存在攻击表示且可改变表示形式的怪兽，并设置改变表示形式的操作信息）
function c91449532.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只攻击表示且可改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91449532.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有攻击表示且可改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(c91449532.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁处理中的操作信息为：改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果②的效果处理（将自己场上的怪兽全部变成表侧守备表示）
function c91449532.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有攻击表示且可改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(c91449532.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
