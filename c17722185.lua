--インヴィンシブル・ヘイロー
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的仪式·融合·同调·超量·灵摆·连接怪兽除外才能发动。这个回合，这张卡在魔法与陷阱区域存在期间，和除外的怪兽相同种类（仪式·融合·同调·超量·灵摆·连接）的怪兽的效果无效化。
function c17722185.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上1只表侧表示的仪式·融合·同调·超量·灵摆·连接怪兽除外才能发动。这个回合，这张卡在魔法与陷阱区域存在期间，和除外的怪兽相同种类（仪式·融合·同调·超量·灵摆·连接）的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCost(c17722185.cost)
	e2:SetOperation(c17722185.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：选出自己场上表侧表示且拥有仪式·融合·同调·超量·灵摆·连接中至少一种种类、并可作为代价除外的怪兽。
function c17722185.cfilter(c)
	return c:IsFaceup() and c:IsType(0x58020C0) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：从自己场上选择1只表侧表示的仪式·融合·同调·超量·灵摆·连接怪兽将其表侧除外，并把该怪兽对应种类的位掩码存入效果的Label，供后续无效化效果使用。
function c17722185.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在至少1只可被选中作为代价除外的表侧表示的指定种类怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17722185.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送选择提示，让玩家从符合条件的怪兽中选出要除外的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上的表侧表示怪兽中精确选择1只满足过滤条件的怪兽，作为本次发动的代价对象。
	local tc=Duel.SelectMatchingCard(tp,c17722185.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	-- 将选中的怪兽以表侧表示除外，完成效果发动所需的代价支付。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	local flag=0
	if tc:IsType(TYPE_RITUAL) then flag=bit.bor(flag,TYPE_RITUAL) end
	if tc:IsType(TYPE_FUSION) then flag=bit.bor(flag,TYPE_FUSION) end
	if tc:IsType(TYPE_SYNCHRO) then flag=bit.bor(flag,TYPE_SYNCHRO) end
	if tc:IsType(TYPE_XYZ) then flag=bit.bor(flag,TYPE_XYZ) end
	if tc:IsType(TYPE_PENDULUM) then flag=bit.bor(flag,TYPE_PENDULUM) end
	if tc:IsType(TYPE_LINK) then flag=bit.bor(flag,TYPE_LINK) end
	e:SetLabel(flag)
end
-- 效果处理：给本卡登记本回合已发动过效果的标记，再创建一个影响双方怪兽区域的无效化效果并登记，使场上与除外怪兽相同种类的怪兽效果无效化。
function c17722185.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(17722185,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local flag=e:GetLabel()
	-- 这个回合，这张卡在魔法与陷阱区域存在期间，和除外的怪兽相同种类（仪式·融合·同调·超量·灵摆·连接）的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17722185.distg)
	e1:SetCondition(c17722185.discon)
	e1:SetLabel(flag)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的无效化效果e1注册到场上，使其在该回合持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 无效化效果的目标判定：若怪兽的种类标识与记录在效果的Label中的除外怪兽种类标识有交集，则该怪兽的效果会被无效。
function c17722185.distg(e,c)
	return c:IsType(e:GetLabel())
end
-- 无效化效果的持续条件：只有发动过效果的这张卡仍存在于场上时，该效果才持续有效。
function c17722185.discon(e)
	return e:GetHandler():GetFlagEffect(17722185)~=0
end
