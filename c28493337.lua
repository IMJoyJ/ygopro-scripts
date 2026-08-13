--終焉の指名者
-- 效果：
-- 把1张手卡从游戏中除外才能发动。双方玩家在这次决斗中不能把为这张卡发动而除外的卡以及那些同名卡的效果发动。
function c28493337.initial_effect(c)
	-- 把1张手卡从游戏中除外才能发动。双方玩家在这次决斗中不能把为这张卡发动而除外的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28493337.cost)
	e1:SetTarget(c28493337.target)
	e1:SetOperation(c28493337.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为发动代价从手牌中除外的卡，即该卡是否允许作为代价除外。
function c28493337.cfilter(c)
	return c:IsAbleToRemoveAsCost()
end
-- 代价处理：确认手牌中有可除外的卡后，选择1张手牌，记录其卡号，并表侧除外作为发动代价；同时用e:SetLabel(1)标记代价已满足。
function c28493337.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查持有者手牌中是否存在至少1张可以作为代价除外的卡，用于确认该效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28493337.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 显示“请选择要除外的卡”的选择提示，引导玩家选择要作为代价除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌中选择1张满足条件的卡，作为本次发动要除外的代价卡。
	local g=Duel.SelectMatchingCard(tp,c28493337.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选择的那张卡以表侧表示从游戏中除外，作为这张卡发动的代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动前的目标合法检查：仅当代价已经通过Label标记为1（即已经支付成功）时才允许发动，同时将Label重置为0；此效果本身不取对象。
function c28493337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return true
	end
end
-- 效果处理时创建一个以双方玩家为对象的永续效果，禁止玩家发动与被除外卡相同卡名的卡的效果；设置判定函数为aclimit，并记录被除外卡的卡号。
function c28493337.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 双方玩家在这次决斗中不能把为这张卡发动而除外的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c28493337.aclimit)
	e1:SetLabel(e:GetLabel())
	-- 将上述禁止发动的永续效果注册到决斗中，控制者为发动这张卡的玩家tp，使其在本次决斗中持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 禁止效果的判定函数：当某玩家发动的效果所属的卡的卡名与记录中被除外卡的卡号一致时，返回true，从而禁止该效果发动。
function c28493337.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
