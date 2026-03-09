--ダイノルフィア・ケントレギナ
-- 效果：
-- 卡名不同的「恐啡肽狂龙」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力下降自己基本分数值。
-- ②：自己·对方的主要阶段，把基本分支付一半，从自己墓地把1张「恐啡肽狂龙」通常陷阱卡除外才能发动。这个效果变成和那张陷阱卡发动时的效果相同。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
function c48832775.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足条件的「恐啡肽狂龙」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c48832775.ffilter,2,true)
	-- ①：这张卡的攻击力下降自己基本分数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c48832775.adval)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把基本分支付一半，从自己墓地把1张「恐啡肽狂龙」通常陷阱卡除外才能发动。这个效果变成和那张陷阱卡发动时的效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,48832775)
	e2:SetCondition(c48832775.cpcon)
	e2:SetCost(c48832775.cpcost)
	e2:SetTarget(c48832775.cptg)
	e2:SetOperation(c48832775.cpop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,48832776)
	e3:SetCondition(c48832775.spcon)
	e3:SetTarget(c48832775.sptg)
	e3:SetOperation(c48832775.spop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数，确保融合怪兽的卡名不重复
function c48832775.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x173) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 计算攻击力下降值，为玩家当前LP的负值
function c48832775.adval(e,c)
	-- 返回玩家当前LP的负值作为攻击力下降量
	return -Duel.GetLP(e:GetHandlerPlayer())
end
-- 判断是否处于主要阶段1或主要阶段2
function c48832775.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2时效果可用
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 陷阱卡过滤函数，筛选墓地中的「恐啡肽狂龙」通常陷阱卡
function c48832775.cpfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x173) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)
end
-- 设置cost标签用于后续处理
function c48832775.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 处理②效果的发动条件与执行流程
function c48832775.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查墓地是否存在满足条件的陷阱卡
		return Duel.IsExistingMatchingCard(c48832775.cpfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	-- 支付当前LP的一半作为代价
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 提示玩家选择要除外的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择一张符合条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c48832775.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选中的陷阱卡除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 执行复制的陷阱卡效果操作
function c48832775.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 判断破坏原因是否为战斗或效果破坏
function c48832775.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤过滤函数，筛选墓地中的4星以下「恐啡肽狂龙」怪兽
function c48832775.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置③效果的目标处理流程
function c48832775.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c48832775.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行③效果的特殊召唤处理流程
function c48832775.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c48832775.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
