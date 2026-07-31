--結合と乖離のアルス＝マグナ
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌除外特召墓地/除外区怪兽与多重攻击授权、②除外区触发特召自身、③/④场上除外墓地卡抽1张效果（符合条件可作诱发即时效果）
function s.initial_effect(c)
	-- ①：把手牌的这张卡除外才能发动。从自己的墓地·除外状态把1只魔法师族以外的「结合与乖离」怪兽特殊召唤。这个回合，自己场上的「阿尔斯」连接怪兽在1次战斗阶段中最多2次可以向怪兽攻击。
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
	-- ②：这张卡在除外状态存在的场合，自己场上有同调·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
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
	-- ③：从自己墓地把1张「结合与乖离」卡除外才能发动。自己抽1张。自己场上有「阿尔斯」连接怪兽存在的场合，这个效果在对方回合也能发动。
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
-- ①效果发动Cost：把手牌的自身表侧表示除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将手牌的自身表侧表示除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 特殊召唤目标过滤：墓地/除外状态非魔法师族的「结合与乖离」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1e6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备与效果目标确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地或除外状态是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从墓地或除外状态特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：特殊召唤选中的怪兽，并赋予己方「阿尔斯」连接怪兽2次怪兽攻击权
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地或除外状态选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 注册全局效果：直到回合结束时，自己场上的「阿尔斯」连接怪兽在1次战斗阶段中最多可以向怪兽作2次攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 连击效果适用对象过滤：自己场上的「阿尔斯」连接怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- ②效果触发条件过滤：表侧表示特殊召唤成功的同调或连接怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO+TYPE_LINK)
end
-- ②效果发动条件：判定是否有除自身以外的同调或连接怪兽特殊召唤
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- ②效果发动准备：检查怪兽区空位与自身特召可能性
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将除外状态的自身表侧表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 诱发即时效果条件过滤：自己场上的「阿尔斯」连接怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 启动效果模式发动条件：不能作诱发即时效果发动或场上没有「阿尔斯」连接怪兽
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否无法获得诱发即时效果的能力
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 或检查自己场上是否存在「阿尔斯」连接怪兽
		or not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 诱发即时效果模式发动条件：能作诱发即时效果发动且场上有「阿尔斯」连接怪兽
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否能获得诱发即时效果的能力
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 且自己场上存在「阿尔斯」连接怪兽
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- Cost过滤条件：自己墓地可除外的「结合与乖离」卡
function s.cfilter2(c)
	return c:IsSetCard(0x1e6) and c:IsAbleToRemoveAsCost()
end
-- ③效果发动Cost：从自己墓地把1张「结合与乖离」卡除外
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己墓地是否存在可除外的「结合与乖离」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1张「结合与乖离」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 把选中的卡表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果发动准备：设置抽卡目标与数量
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡参数为1张
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ③效果处理：执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家及抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
