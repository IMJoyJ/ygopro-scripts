--BF－蒼炎のシュラ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只攻击力1500以下的「黑羽」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c58820853.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只攻击力1500以下的「黑羽」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58820853,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为自身战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c58820853.target)
	e1:SetOperation(c58820853.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中攻击力1500以下且可以特殊召唤的「黑羽」怪兽
function c58820853.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测函数
function c58820853.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自身场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查卡组中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c58820853.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c58820853.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自身场上没有可用的怪兽区域空格则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c58820853.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选择的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
