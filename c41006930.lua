--速攻の黒い忍者
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：从自己墓地把2只暗属性怪兽除外才能发动。表侧表示的这张卡直到结束阶段除外。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 创建并注册一个诱发即时效果，允许在主要阶段发动，将自身除外，且该效果每回合只能发动一次
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
-- 过滤函数，用于判断墓地中的卡是否为正面表示的暗属性怪兽且可以作为除外的代价
function c41006930.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理，检查是否满足除外2只暗属性怪兽的条件，并选择并除外这些怪兽
function c41006930.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外2只暗属性怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c41006930.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2只暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c41006930.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的怪兽除外作为发动效果的费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标为自身，准备发动时的处理
function c41006930.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置效果操作信息，表示将自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理函数，将自身以暂时除外的形式除外，并在结束阶段返回场上
function c41006930.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否正面表示、是否与效果相关、是否成功除外且为原卡号
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		-- 在结束阶段将自身返回到场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c41006930.retop)
		-- 将效果注册到玩家环境中，使其在指定时机触发
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回场上的效果处理函数，将指定卡返回到场上
function c41006930.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将指定卡以原表示形式返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
