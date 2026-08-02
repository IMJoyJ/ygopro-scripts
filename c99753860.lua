--結合と乖離のアルス＝マグナ
local s,id,o=GetID()
-- 初始化卡片，注册特殊召唤、抽卡等4个效果
function s.initial_effect(c)
	-- 效果①：把这张卡从手卡除外才能发动。从自己墓地·除外状态的怪兽中选1只特定怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在除外状态存在，额外卡组有同调·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 效果③：从自己墓地把1只特定怪兽除外才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon1)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_DRAW_PHASE+TIMING_END_PHASE)
	e4:SetCondition(s.rmcon2)
	c:RegisterEffect(e4)
end
-- 发动的代价：将此卡自身从手卡除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将此卡自身表侧表示除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 过滤条件：魔法师族以外的特定字段怪兽，且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1e6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查自己场上是否有空余的怪兽区域，且墓地或除外状态存在满足特殊召唤条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地或除外状态是否存在满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置效果的预期操作：从墓地或除外状态特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 从墓地或除外状态选1只满足条件的怪兽特殊召唤，并为指定连接怪兽赋予可作2次攻击的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上还有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从墓地或除外状态选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 那之后，自己场上的特定连接怪兽在同1次战斗阶段中可以对怪兽作2次攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该多次攻击的永续效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：特定的连接怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 过滤条件：表侧表示的同调或连接怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO+TYPE_LINK)
end
-- 判断是否有除此卡自身以外的同调或连接怪兽被特殊召唤
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- 检查自己场上是否有空余的怪兽区域，且此卡自身可以被特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果的预期操作：将此卡自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 如果此卡仍在触发位置，则将其特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：特定的连接怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 判断条件：当前不能作为诱发即时效果发动，或者自己场上不存在特定的连接怪兽
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否不能作为诱发即时效果发动
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 或者自己场上不存在满足条件的特定连接怪兽
		or not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断条件：当前可以作为诱发即时效果发动，并且自己场上存在特定的连接怪兽
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否可以作为诱发即时效果发动
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 并且自己场上存在满足条件的特定连接怪兽
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：特定的怪兽，且可以作为代价被除外
function s.cfilter2(c)
	return c:IsSetCard(0x1e6) and c:IsAbleToRemoveAsCost()
end
-- 发动的代价：从自己墓地选1只满足条件的怪兽除外
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以作为代价除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查玩家是否可以抽卡，并设置抽卡的预期操作
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前玩家设置为连锁的对象玩家
	Duel.SetTargetPlayer(tp)
	-- 将抽卡数量1设置为连锁的对象参数
	Duel.SetTargetParam(1)
	-- 设置效果的预期操作：让目标玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 获取目标玩家和抽卡数量参数，并执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
