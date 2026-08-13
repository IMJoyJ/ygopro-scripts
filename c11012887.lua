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
	-- 设置效果的发动条件：这张卡与对方怪兽进行战斗并将其战斗破坏（即满足“这张卡战斗破坏对方怪兽时”的场合）。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c11012887.target)
	e1:SetOperation(c11012887.operation)
	c:RegisterEffect(e1)
end
-- 定义检索/特殊召唤的筛选条件：从卡组中选出的怪兽必须包含「朱罗纪」字段、攻击力在1700以下，并且能够被效果特殊召唤。
function c11012887.filter(c,e,tp)
	return c:IsSetCard(0x22) and c:IsAttackBelow(1700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：需要我方主要怪兽区有空位，并且卡组中存在符合过滤条件的「朱罗纪」怪兽，才能发动这个效果。
function c11012887.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用空格，确保有地方可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件（攻击力1700以下且为「朱罗纪」怪兽）的卡。
		and Duel.IsExistingMatchingCard(c11012887.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理时的操作信息：本次效果将进行特殊召唤，对象来自卡组，数量为1，归属玩家为tp，用于给其他卡（如星尘龙等）提供发动检测信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先确认主要怪兽区仍有空位，然后让玩家从卡组选择1只符合条件的「朱罗纪」怪兽表侧表示特殊召唤；若特殊召唤成功，则给该怪兽附加“这个回合不能攻击宣言”的效果。
function c11012887.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否还有可用空格，若没有空格则特殊召唤无法进行，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中筛选并选择1只满足过滤条件（攻击力1700以下且为「朱罗纪」怪兽）的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c11012887.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽以表侧表示特殊召唤到我的场上；若特殊召唤成功（返回值不为0），则继续给该怪兽附加不能攻击宣言的效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击宣言。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
