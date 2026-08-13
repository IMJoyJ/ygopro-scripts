--真竜剣皇マスターP
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
-- ①：这张卡不受和为这张卡的上级召唤而解放的卡的原本种类（怪兽·魔法·陷阱）相同种类的效果影响。
-- ②：这张卡是已上级召唤的场合，自己·对方回合1次，从自己墓地把1张永续魔法·永续陷阱卡除外，以场上1张其他卡为对象才能发动。那张卡破坏。
function c21377582.initial_effect(c)
	-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 筛选可作为额外祭品的卡，限定为本方魔陷区的永续魔法·永续陷阱卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- ①：这张卡不受和为这张卡的上级召唤而解放的卡的原本种类（怪兽·魔法·陷阱）相同种类的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c21377582.valcheck)
	c:RegisterEffect(e2)
	-- ①：这张卡不受和为这张卡的上级召唤而解放的卡的原本种类（怪兽·魔法·陷阱）相同种类的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c21377582.regcon)
	e3:SetOperation(c21377582.regop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：这张卡是已上级召唤的场合，自己·对方回合1次，从自己墓地把1张永续魔法·永续陷阱卡除外，以场上1张其他卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21377582,2))  --"场上卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c21377582.descon)
	e4:SetCost(c21377582.descost)
	e4:SetTarget(c21377582.destg)
	e4:SetOperation(c21377582.desop)
	c:RegisterEffect(e4)
end
-- 遍历上级召唤的素材，提取其原本种类（怪兽/魔法/陷阱）并合并为类型掩码，存入效果标签，供免疫效果判断。
function c21377582.valcheck(e,c)
	local g=c:GetMaterial()
	local typ=0
	local tc=g:GetFirst()
	while tc do
		typ=bit.bor(typ,bit.band(tc:GetOriginalType(),0x7))
		tc=g:GetNext()
	end
	e:SetLabel(typ)
end
-- 判定召唤成功时是否为上级召唤。
function c21377582.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据解放素材的种类，注册对应种类的效果免疫效果，并添加客户端提示（解放怪兽卡/魔法卡/陷阱卡）。
function c21377582.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ=e:GetLabelObject():GetLabel()
	-- ①：这张卡不受和为这张卡的上级召唤而解放的卡的原本种类（怪兽·魔法·陷阱）相同种类的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c21377582.efilter)
	e1:SetLabel(typ)
	c:RegisterEffect(e1)
	if bit.band(typ,TYPE_MONSTER)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21377582,3))  --"解放怪兽卡上级召唤"
	end
	if bit.band(typ,TYPE_SPELL)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21377582,4))  --"解放魔法卡上级召唤"
	end
	if bit.band(typ,TYPE_TRAP)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21377582,5))  --"解放陷阱卡上级召唤"
	end
end
-- 判断需要免疫的效果是否来自与解放素材相同原本种类的卡，且该效果的所有者不是本卡（避免免疫自己的效果）。
function c21377582.efilter(e,te)
	return te:GetHandler():GetOriginalType()&e:GetLabel()~=0 and te:GetOwner()~=e:GetOwner()
end
-- 判定这张卡是否为已上级召唤状态。
function c21377582.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选可作为代价除外的卡：从墓地选择永续魔法·永续陷阱卡且能够除外。
function c21377582.costfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsAbleToRemoveAsCost()
end
-- 支付发动代价：从自己墓地选择1张永续魔法·永续陷阱卡除外。
function c21377582.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张满足代价条件的永续魔法·永续陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21377582.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出“请选择要除外的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张永续魔法·永续陷阱卡作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c21377582.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为发动②效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果取对象：选择场上这张卡以外的1张卡为效果对象。
function c21377582.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 检查场上是否存在这张卡以外的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 向玩家发出“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择1张这张卡以外的卡作为破坏对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息，将选中的对象标记为破坏（CATEGORY_DESTROY），便于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时，若对象仍与效果关联，则将其破坏。
function c21377582.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
