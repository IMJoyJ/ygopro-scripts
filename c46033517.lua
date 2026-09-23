--マシンナーズ・ルインフォース
-- 效果：
-- 这张卡不能通常召唤。把等级合计直到12以上的自己墓地的机械族怪兽除外的场合才能从墓地特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：战斗阶段对方把效果发动时，把基本分支付一半才能发动。那个发动无效，对方基本分变成一半。
-- ②：这张卡被战斗·效果破坏的场合才能发动。等级合计最多到12星以下为止，选除外的最多3只自己的「机甲」怪兽特殊召唤。
function c46033517.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把等级合计直到12以上的自己墓地的机械族怪兽除外的场合才能从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c46033517.hspcon)
	e2:SetTarget(c46033517.hsptg)
	e2:SetOperation(c46033517.hspop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：战斗阶段对方把效果发动时，把基本分支付一半才能发动。那个发动无效，对方基本分变成一半。
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
	-- ②：这张卡被战斗·效果破坏的场合才能发动。等级合计最多到12星以下为止，选除外的最多3只自己的「机甲」怪兽特殊召唤。
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
-- 过滤墓地中可以除外作为特殊召唤代价的机械族怪兽
function c46033517.hspfilter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查怪兽等级合计是否达到12以上
function c46033517.hspcheck(g)
	-- 设置必须包含已选卡片组
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,12)
end
-- 子分组选择辅助检查：等级未满12时允许继续选择，达到12以上停止选择更多
function c46033517.hspgcheck(g)
	if g:GetSum(Card.GetLevel)<=12 then return true end
	-- 设置必须包含已选卡片组
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,12)
end
-- 特殊召唤手续条件判断
function c46033517.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取主要怪兽区空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return false end
	-- 获取墓地中符合除外条件的机械族怪兽
	local g=Duel.GetMatchingGroup(c46033517.hspfilter,tp,LOCATION_GRAVE,0,c)
	-- 设置选择子分组的追加检查函数
	aux.GCheckAdditional=c46033517.hspgcheck
	local res=g:CheckSubGroup(c46033517.hspcheck,1,#g)
	-- 清空追加检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 选择墓地除外作为特殊召唤手续的怪兽
function c46033517.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取墓地中符合除外条件的机械族怪兽
	local g=Duel.GetMatchingGroup(c46033517.hspfilter,tp,LOCATION_GRAVE,0,c)
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置选择子分组的追加检查函数
	aux.GCheckAdditional=c46033517.hspgcheck
	local sg=g:SelectSubGroup(tp,c46033517.hspcheck,true,1,#g)
	-- 清空追加检查函数
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续处理：除外选中的怪兽
function c46033517.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 效果发动代价：支付一半基本分
function c46033517.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 效果发动条件：战斗阶段对方发动效果
function c46033517.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	-- 检查自身未被战斗破坏、该连锁可以无效且是对方发动的效果
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 效果发动检查与设置操作信息：使发动无效
function c46033517.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理：那个发动无效，对方基本分变成一半
function c46033517.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的发动无效
	if Duel.NegateActivation(ev) then
		-- 将对方基本分减半
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
-- 效果发动条件：被战斗·效果破坏
function c46033517.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤除外区可以特殊召唤的「机甲」怪兽
function c46033517.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x36) and c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动检查与设置操作信息：特殊召唤除外的「机甲」怪兽
function c46033517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认怪兽区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认除外区存在可以特殊召唤的「机甲」怪兽
		and Duel.IsExistingMatchingCard(c46033517.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：从除外区特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 检查选中的怪兽等级合计是否在12以下
function c46033517.spcheck(g)
	return g:GetSum(Card.GetLevel)<=12
end
-- 效果处理：从除外区特殊召唤最多3只等级合计12以下的「机甲」怪兽
function c46033517.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的怪兽数量上限（最多3只）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 获取除外区可以特殊召唤的「机甲」怪兽
	local tg=Duel.GetMatchingGroup(c46033517.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置等级合计12以下的检查函数
	aux.GCheckAdditional=c46033517.spcheck
	-- 选择最多3只等级合计12以下的怪兽
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
	-- 清空检查函数
	aux.GCheckAdditional=nil
	-- 将选中的怪兽表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
