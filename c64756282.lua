--ウィッチクラフト・ジェニー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·万能杰妮」以外的1只「魔女术」怪兽特殊召唤。
-- ②：从自己墓地把这张卡和1张「魔女术」魔法卡除外才能发动。这个效果变成和那张魔法卡发动时的效果相同。
function c64756282.initial_effect(c)
	-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·万能杰妮」以外的1只「魔女术」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64756282,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,64756282)
	e1:SetCondition(c64756282.spcon)
	e1:SetCost(c64756282.spcost)
	e1:SetTarget(c64756282.sptg)
	e1:SetOperation(c64756282.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1张「魔女术」魔法卡除外才能发动。这个效果变成和那张魔法卡发动时的效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64756282,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,64756283)
	e2:SetCost(c64756282.cpcost)
	e2:SetTarget(c64756282.cptg)
	e2:SetOperation(c64756282.cpop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动条件判断函数
function c64756282.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function c64756282.costfilter(c,tp,res)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
		or not c:IsCode(32353566) and c:IsSetCard(0x128)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and c:IsLocation(LOCATION_DECK) and res
end
-- ①号效果的发动代价处理函数
function c64756282.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local res=Duel.IsPlayerAffectedByEffect(tp,32353566) and e:GetHandler():IsSetCard(0x128)
	if chk==0 then return e:GetHandler():IsReleasable()
		and Duel.IsExistingMatchingCard(c64756282.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp,res) end
	local g=Duel.GetMatchingGroup(c64756282.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil,tp,res)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.Release(e:GetHandler(),REASON_COST)
	if not tc:IsLocation(LOCATION_HAND) then
		local te=tc:IsHasEffect(83289866,tp)
		if te then
			te:UseCountLimit(tp)
			Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SendtoGrave(tc,REASON_COST)
	else
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤卡组中「魔女术工匠·万能杰妮」以外的「魔女术」怪兽
function c64756282.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(64756282) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动检查与效果分类设置函数
function c64756282.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放自身后是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在可特殊召唤的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c64756282.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤卡组中1张怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的效果处理函数
function c64756282.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域已满则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择卡组中1只满足条件的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c64756282.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤墓地中可复制效果的「魔女术」魔法卡
function c64756282.cpfilter(c,exc,e,tp,eg,ep,ev,re,r,rp)
	local te=c:CheckActivateEffect(true,true,false)
	if not (c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost() and te and te:GetOperation()) then return false end
	local tg=te:GetTarget()
	return (not tg) or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,exc)
end
-- ②号效果的发动代价处理函数
function c64756282.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在可复制效果的「魔女术」魔法卡
		and Duel.IsExistingMatchingCard(c64756282.cpfilter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp,eg,ep,ev,re,r,rp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择墓地中1张要复制效果的「魔女术」魔法卡
	local g=Duel.SelectMatchingCard(tp,c64756282.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp,eg,ep,ev,re,r,rp)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	g:AddCard(c)
	-- 将选中的卡和自身一同除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②号效果的目标选择与效果复制初始化函数
function c64756282.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local te=e:GetLabelObject()
	if chkc then
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc,c)
	end
	if chk==0 then return true end
	e:SetProperty(te:GetProperty())
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息（因为复制效果不应被直接响应）
	Duel.ClearOperationInfo(0)
end
-- ②号效果的效果处理函数（执行被复制魔法卡的效果）
function c64756282.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
end
