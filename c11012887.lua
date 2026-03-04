--ジュラック・グアイバ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只攻击力1700以下的「朱罗纪」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击宣言。
function c11012887.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只攻击力1700以下的「朱罗纪」怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11012887,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否满足效果发动条件：该怪兽是否与对方怪兽战斗并破坏了对方怪兽
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c11012887.target)
	e1:SetOperation(c11012887.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「朱罗纪」怪兽：攻击力不超过1700且可以被特殊召唤
function c11012887.filter(c,e,tp)
	return c:IsSetCard(0x22) and c:IsAttackBelow(1700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理目标函数，用于判断是否可以发动此效果
function c11012887.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：玩家场上是否有空位且卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件：玩家场上是否有空位且卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c11012887.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，用于执行效果内容
function c11012887.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位，如果没有则不执行后续操作
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c11012887.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击宣言
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
