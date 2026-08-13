--速攻の黒い忍者
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：从自己墓地把2只暗属性怪兽除外才能发动。表侧表示的这张卡直到结束阶段除外。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 定义并注册这张卡的核心效果：在主要怪兽区可当作诱发即时效果（二速）自由时点发动；支付从自己墓地除外2只暗属性怪兽的代价，将表侧表示的自身暂时除外直到结束阶段，并限定此卡名效果1回合只能使用1次。
function c41006930.initial_effect(c)
	-- ①：从自己墓地把2只暗属性怪兽除外才能发动。表侧表示的这张卡直到结束阶段除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41006930,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41006930)
	e1:SetCost(c41006930.rmcost)
	e1:SetTarget(c41006930.rmtg)
	e1:SetOperation(c41006930.rmop)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：用于选择自己墓地中表侧表示、暗属性、且可以作为代价除外的怪兽。
function c41006930.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 代价函数：在发动时确认墓地是否存在2只满足条件的暗属性怪兽，存在则让玩家选择2张，并作为代价以表侧表示除外。
function c41006930.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否能支付代价：检查自己墓地是否存在至少2张满足cfilter条件的暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41006930.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向操作玩家发送选择提示消息，内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只满足cfilter条件的暗属性怪兽，作为本次发动要支付的代价。
	local g=Duel.SelectMatchingCard(tp,c41006930.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的怪兽卡以表侧表示除外，除外原因记为REASON_COST（作为代价），完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标函数：确认自身能够被除外，并设置本次效果处理时将除外自身的信息，用于发动时的合法性检查和后续时点判定。
function c41006930.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置操作信息：本次效果要处理的分类为除外，对象为效果发动者自身，数量为1，使系统在执行效果前正确记录除外自身的意图。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若自身仍表侧表示且与效果有联系，则将其以表侧表示暂时除外；成功后注册一个在结束阶段将自身返回场上的连续效果。
function c41006930.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定并执行暂时除外：自身必须表侧表示且与发动时的效果关联，随后用REASON_EFFECT+REASON_TEMPORARY（效果且暂时）将自身除外；若除外成功且原始卡号仍为本卡，则继续注册结束阶段返回的处理。
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		-- 表侧表示的这张卡直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c41006930.retop)
		-- 将新建的结束阶段返回效果注册到当前玩家，使得本回合结束阶段自动把暂时除外的这张卡返回场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回效果的处理函数：将之前被暂时除外的这张卡（通过LabelObject记录）返回场上。
function c41006930.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 把被暂时除外的这张卡按原表示形式返回到场上，完成“直到结束阶段除外”后的回归处理。
	Duel.ReturnToField(e:GetLabelObject())
end
