--双天の使命
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，把「双天的使命」以外的自己墓地1张「双天」魔法·陷阱卡除外才能发动。这张卡的效果变成和那张魔法·陷阱卡发动时的效果相同。
function c75157704.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，把「双天的使命」以外的自己墓地1张「双天」魔法·陷阱卡除外才能发动。这张卡的效果变成和那张魔法·陷阱卡发动时的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,75157704+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:SetCondition(c75157704.condition)
	e1:SetCost(c75157704.cost)
	e1:SetTarget(c75157704.target)
	e1:SetOperation(c75157704.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数：只能在自己或对方的主要阶段发动。
function c75157704.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前游戏阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义效果发动的代价函数：将Label设为1以标记是通过Cost检测。
function c75157704.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：检索自己墓地中「双天的使命」以外的、且可以发动效果的「双天」魔法·陷阱卡。
function c75157704.filter(c)
	return c:IsSetCard(0x14f) and not c:IsCode(75157704) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:CheckActivateEffect(false,true,false)~=nil
end
-- 定义效果发动的目标选择与复制处理函数：在发动时除外墓地的卡作为代价，并复制该卡发动时的效果与属性。
function c75157704.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查自己墓地是否存在至少1张满足过滤条件的「双天」魔法·陷阱卡。
		return Duel.IsExistingMatchingCard(c75157704.filter,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足过滤条件的「双天」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c75157704.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选择的卡片表侧表示除外作为发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止该效果被其他卡片响应。
	Duel.ClearOperationInfo(0)
end
-- 定义效果处理函数：获取并执行被复制卡片效果的Operation操作。
function c75157704.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
