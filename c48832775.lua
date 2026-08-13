--ダイノルフィア・ケントレギナ
-- 效果：
-- 卡名不同的「恐啡肽狂龙」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力下降自己基本分数值。
-- ②：自己·对方的主要阶段，把基本分支付一半，从自己墓地把1张「恐啡肽狂龙」通常陷阱卡除外才能发动。这个效果变成和那张陷阱卡发动时的效果相同。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己墓地选1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
function c48832775.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只满足ffilter条件的「恐啡肽狂龙」怪兽（卡名不同）作为融合素材进行融合召唤。
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
-- 融合素材过滤函数：素材必须是「恐啡肽狂龙」字段的怪兽，且不能与已选素材的融合代码重复，以此满足“卡名不同”的融合素材条件。
function c48832775.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x173) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 效果①的攻击力变化值计算函数：返回自己当前基本分的负值，使这张卡的攻击力下降对应的基本分数值。
function c48832775.adval(e,c)
	-- 取出这张卡控制者的当前基本分并取负，作为攻击力下降数值。
	return -Duel.GetLP(e:GetHandlerPlayer())
end
-- ②效果的发动条件：当前阶段为自己或对方的主要阶段时才能发动。
function c48832775.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 墓地陷阱卡过滤函数：选择「恐啡肽狂龙」字段的通常陷阱卡，要求能够除外作为代价且具备可发动的效果。
function c48832775.cpfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x173) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)
end
-- 代价检查函数：在合法性检查阶段将Label标记为1表示代价可支付；实际支付基本分和除外陷阱卡的操作在Target阶段完成。
function c48832775.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- ②效果发动时：确认墓地存在合法对象后，支付一半基本分，从自己墓地选择1张「恐啡肽狂龙」通常陷阱卡除外，取得该陷阱卡的发动效果数据并保存，用于后续复制效果。
function c48832775.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查自己墓地是否存在至少1张符合cpfilter条件的「恐啡肽狂龙」通常陷阱卡。
		return Duel.IsExistingMatchingCard(c48832775.cpfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	-- 支付当前基本分的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 向玩家显示选择提示「请选择要除外的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张符合cpfilter条件的「恐啡肽狂龙」通常陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c48832775.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选择的陷阱卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，避免复制出的陷阱效果在发动判定时被当作应被响应的新效果。
	Duel.ClearOperationInfo(0)
end
-- 效果处理时，取出之前保存的被复制陷阱卡效果，调用其Operation函数来执行与那张陷阱卡发动时相同的效果。
function c48832775.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- ③效果的发动条件：这张卡被战斗或效果破坏的场合才能发动。
function c48832775.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- ③效果的特殊召唤对象过滤：选择4星以下、持有「恐啡肽狂龙」字段且满足特殊召唤条件的怪兽。
function c48832775.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动检查：自己场上存在可用怪兽区域，且自己墓地存在符合条件的「恐啡肽狂龙」怪兽。
function c48832775.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在至少1只符合spfilter的「恐啡肽狂龙」怪兽作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c48832775.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果预计从墓地特殊召唤1只怪兽到自己场上（对象在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：若场上仍有空位，则从自己墓地选择1只符合条件的「恐啡肽狂龙」怪兽，以表侧表示特殊召唤。
function c48832775.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用怪兽区域，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合spfilter条件的「恐啡肽狂龙」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c48832775.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上，并进行常规特殊召唤合法性检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
