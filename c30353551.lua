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
		-- 其数量等于在同1回合中自己被战斗破坏的2星以下的通常怪兽的数量。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(c30353551.checkop)
		-- 将战斗破坏计数用的全局效果注册到游戏中，在每次伤害计算后（EVENT_BATTLED）触发，用于累计本回合双方被战斗破坏的2星以下通常怪兽的数量。
		Duel.RegisterEffect(ge1,0)
		-- 其数量等于在同1回合中自己被战斗破坏的2星以下的通常怪兽的数量。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c30353551.clear)
		-- 将每回合重置计数用的全局效果注册到游戏中，在抽卡阶段开始时（EVENT_PHASE_START+PHASE_DRAW）将双方计数清零，确保统计的是同一回合内的数量。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 本回合内每次战斗伤害计算后，若攻击怪兽或被攻击怪兽因战斗被破坏且为2星以下通常怪兽，则将对应控制者的本回合计数加1。
function c30353551.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗中的被攻击对象（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	if a:IsStatus(STATUS_BATTLE_DESTROYED) and a:IsType(TYPE_NORMAL) and a:IsLevelBelow(2) then
		c30353551[a:GetControler()]=c30353551[a:GetControler()]+1
	end
	if d and d:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsType(TYPE_NORMAL) and d:IsLevelBelow(2) then
		c30353551[d:GetControler()]=c30353551[d:GetControler()]+1
	end
end
-- 将玩家0和玩家1的计数清零，用于在新回合开始时重置本回合被战斗破坏的2星以下通常怪兽数量统计。
function c30353551.clear(e,tp,eg,ep,ev,re,r,rp)
	c30353551[0]=0
	c30353551[1]=0
end
-- 筛选可特殊召唤的卡：满足2星以下、通常怪兽且能被此效果特殊召唤。
function c30353551.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动时的判定：本回合计数大于0，且若计数大于1时场上没有禁止同时特殊召唤2只以上怪兽的效果（如青眼精灵龙）则满足发动条件；并将特殊召唤的信息写入连锁操作。
function c30353551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=c30353551[tp]
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) end
	-- 设置当前连锁的操作信息，宣告从卡组特殊召唤ct只怪兽，供相关效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择ct张符合条件的通常怪兽；若怪兽区空格不足则调整特召数量，能全特召则全部特召，否则特召可用空格数的怪兽并将剩余卡送去墓地；同时若青眼精灵龙效果适用中，每次最多特殊召唤1只。
function c30353551.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=c30353551[tp]
	-- 向玩家显示'请选择要特殊召唤的卡'的提示消息，用于选择特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择ct张满足filter条件的卡（2星以下通常怪兽且可特殊召唤），这些卡将成为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c30353551.filter,tp,LOCATION_DECK,0,ct,ct,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 获取自己场上主要怪兽区的可用空格数，以判断能否全部特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<=0 then
		-- 当可用怪兽区空格为0时，将选出的所有卡送去墓地（因无空格可特殊召唤）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif ft>=g:GetCount() then
		-- 当可用怪兽区空格足够时，将选出的所有怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 在只能特殊召唤部分怪兽时，再次提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选中的部分怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将因可用怪兽区不足而未能特殊召唤的剩余卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
