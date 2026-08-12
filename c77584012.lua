--擬似空間
-- 效果：
-- ①：1回合1次，从自己墓地把1张场地魔法卡除外才能发动。直到结束阶段，这张卡当作和除外的卡同名卡使用，得到相同效果。
function c77584012.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己墓地把1张场地魔法卡除外才能发动。直到结束阶段，这张卡当作和除外的卡同名卡使用，得到相同效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77584012,0))  --"获得场地魔法卡的效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c77584012.cost)
	e2:SetOperation(c77584012.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为代价除外的场地魔法卡
function c77584012.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：检查本回合是否尚未发动过此效果，且自己墓地是否存在可作为代价除外的场地魔法卡
function c77584012.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(77584012)==0
		-- 检查自己墓地是否存在至少1张满足过滤条件的场地魔法卡
		and Duel.IsExistingMatchingCard(c77584012.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中的1张场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c77584012.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local code=g:GetFirst():GetOriginalCode()
	e:SetLabel(code)
	-- 将选择的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RegisterFlagEffect(77584012,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果处理：使这张卡直到结束阶段当作被除外卡的同名卡使用，并获得其效果，同时注册一个在结束阶段重置复制效果的延迟效果
function c77584012.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	-- 直到结束阶段，这张卡当作和除外的卡同名卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	-- 直到结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77584012,1))  --"结束复制效果"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetLabel(cid)
	e2:SetLabelObject(e1)
	e2:SetOperation(c77584012.rstop)
	c:RegisterEffect(e2)
end
-- 在结束阶段重置复制的卡名和效果
function c77584012.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 为这张卡显示被选为效果影响对象的动画
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“结束复制效果”的操作
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
