--マシンナーズ・ルインフォース
-- 效果：
-- 这张卡不能通常召唤。把等级合计直到12以上的自己墓地的机械族怪兽除外的场合才能从墓地特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：战斗阶段对方把效果发动时，把基本分支付一半才能发动。那个发动无效，对方基本分变成一半。
-- ②：这张卡被战斗·效果破坏的场合才能发动。等级合计最多到12星以下为止，选除外的最多3只自己的「机甲」怪兽特殊召唤。
function c46033517.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：把等级合计直到12以上的自己墓地的机械族怪兽除外的场合才能从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c46033517.hspcon)
	e2:SetTarget(c46033517.hsptg)
	e2:SetOperation(c46033517.hspop)
	c:RegisterEffect(e2)
	-- 效果原文：①：战斗阶段对方把效果发动时，把基本分支付一半才能发动。那个发动无效，对方基本分变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46033517,0))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,46033517)
	e3:SetCost(c46033517.negcost)
	e3:SetCondition(c46033517.negcon)
	e3:SetTarget(c46033517.negtg)
	e3:SetOperation(c46033517.negop)
	c:RegisterEffect(e3)
	-- 效果原文：②：这张卡被战斗·效果破坏的场合才能发动。等级合计最多到12星以下为止，选除外的最多3只自己的「机甲」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46033517,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,46033518)
	e4:SetCondition(c46033517.spcon)
	e4:SetTarget(c46033517.sptg)
	e4:SetOperation(c46033517.spop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的墓地机械族怪兽（等级≥1，可作为除外费用）
function c46033517.hspfilter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查所选卡片组的等级总和是否大于等于12
function c46033517.hspcheck(g)
	-- 设置当前选中的卡片组，用于后续的CheckWithSumGreater函数
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,12)
end
-- 检查所选卡片组的等级总和是否小于等于12，否则设置选中卡片组
function c46033517.hspgcheck(g)
	if g:GetSum(Card.GetLevel)<=12 then return true end
	-- 设置当前选中的卡片组，用于后续的CheckWithSumGreater函数
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,12)
end
-- 检查是否满足特殊召唤条件：墓地满足条件的机械族怪兽等级总和≥12
function c46033517.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	-- 获取满足条件的墓地机械族怪兽组
	local g=Duel.GetMatchingGroup(c46033517.hspfilter,tp,LOCATION_GRAVE,0,c)
	-- 设置额外的检查函数，用于特殊召唤时的等级总和判断
	aux.GCheckAdditional=c46033517.hspgcheck
	local res=g:CheckSubGroup(c46033517.hspcheck,1,#g)
	-- 清除额外的检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 选择满足条件的墓地机械族怪兽组并设置为除外
function c46033517.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的墓地机械族怪兽组
	local g=Duel.GetMatchingGroup(c46033517.hspfilter,tp,LOCATION_GRAVE,0,c)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置额外的检查函数，用于特殊召唤时的等级总和判断
	aux.GCheckAdditional=c46033517.hspgcheck
	local sg=g:SelectSubGroup(tp,c46033517.hspcheck,true,1,#g)
	-- 清除额外的检查函数
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将选中的卡片组除外
function c46033517.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将卡片组从游戏中除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 支付一半基本分作为发动代价
function c46033517.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付玩家当前基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 判断是否满足发动条件：当前为战斗阶段且对方发动了效果
function c46033517.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	-- 判断是否满足发动条件：当前为战斗阶段且对方发动了效果
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 设置操作信息：使对方效果无效
function c46033517.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 使对方效果无效并将其基本分变为一半
function c46033517.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使对方效果无效
	if Duel.NegateActivation(ev) then
		-- 将对方基本分变为一半
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
-- 判断是否满足发动条件：被战斗或效果破坏
function c46033517.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 检索满足条件的除外的「机甲」怪兽（等级≥1，可特殊召唤）
function c46033517.spfilter(c,e,tp)
	return c:IsSetCard(0x36) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤目标：场上存在满足条件的除外「机甲」怪兽
function c46033517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在满足条件的除外「机甲」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：场上存在满足条件的除外「机甲」怪兽
		and Duel.IsExistingMatchingCard(c46033517.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤除外的「机甲」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 检查所选卡片组的等级总和是否小于等于12
function c46033517.spcheck(g)
	return g:GetSum(Card.GetLevel)<=12
end
-- 特殊召唤满足条件的除外「机甲」怪兽
function c46033517.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前场上可用的怪兽区域数量并限制最多3只
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 获取满足条件的除外「机甲」怪兽组
	local tg=Duel.GetMatchingGroup(c46033517.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置额外的检查函数，用于特殊召唤时的等级总和判断
	aux.GCheckAdditional=c46033517.spcheck
	-- 选择满足条件的除外「机甲」怪兽组并进行特殊召唤
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
	-- 清除额外的检查函数
	aux.GCheckAdditional=nil
	-- 将选中的卡片组特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
