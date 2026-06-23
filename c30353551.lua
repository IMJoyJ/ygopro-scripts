--人海戦術
-- 效果：
-- 在每1个回合的结束阶段时，自己从卡组中选择2星以下的通常怪兽特殊召唤上场，其数量等于在同1回合中自己被战斗破坏的2星以下的通常怪兽的数量。
function c30353551.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 在每1个回合的结束阶段时，自己从卡组中选择2星以下的通常怪兽特殊召唤上场，其数量等于在同1回合中自己被战斗破坏的2星以下的通常怪兽的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30353551,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(c30353551.target)
	e2:SetOperation(c30353551.operation)
	c:RegisterEffect(e2)
	if not c30353551.global_check then
		c30353551.global_check=true
		-- 检测在战斗阶段中被战斗破坏的2星以下的通常怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c30353551.checkop)
		-- 将效果注册到全局环境，使该效果在游戏场地上生效
		Duel.RegisterEffect(ge1,0)
		-- 在每个抽卡阶段开始时，将记录的被战斗破坏怪兽数量清零
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c30353551.clear)
		-- 将效果注册到全局环境，使该效果在游戏场地上生效
		Duel.RegisterEffect(ge2,0)
	end
end
-- 记录在战斗阶段中被战斗破坏的2星以下的通常怪兽数量
function c30353551.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取此次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if a:IsStatus(STATUS_BATTLE_DESTROYED) and a:IsType(TYPE_NORMAL) and a:IsLevelBelow(2) then
		c30353551[a:GetControler()]=c30353551[a:GetControler()]+1
	end
	if d and d:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsType(TYPE_NORMAL) and d:IsLevelBelow(2) then
		c30353551[d:GetControler()]=c30353551[d:GetControler()]+1
	end
end
-- 清空双方被战斗破坏怪兽数量的记录
function c30353551.clear(e,tp,eg,ep,ev,re,r,rp)
	c30353551[0]=0
	c30353551[1]=0
end
-- 过滤满足条件的2星以下通常怪兽
function c30353551.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁操作信息，确定特殊召唤怪兽的数量和来源
function c30353551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=c30353551[tp]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) end
	-- 设置当前处理的连锁的操作信息，包含特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，根据场上空位决定是否全部特殊召唤或部分特殊召唤
function c30353551.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=c30353551[tp]
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c30353551.filter,tp,LOCATION_DECK,0,ct,ct,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<=0 then
		-- 将目标怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif ft>=g:GetCount() then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将部分目标怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将剩余目标怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
