--スターヴ・ヴェノム・フュージョン・ドラゴン
-- 效果：
-- 衍生物以外的场上的暗属性怪兽×2
-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升对方场上1只特殊召唤的怪兽的攻击力数值。
-- ②：1回合1次，以对方场上1只5星以上的怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
-- ③：融合召唤的这张卡被破坏的场合才能发动。对方场上的特殊召唤的怪兽全部破坏。
function c41209827.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：以衍生物以外的场上2只暗属性怪兽作为融合素材来融合召唤。
	aux.AddFusionProcFunRep(c,c41209827.ffilter,2,true)
	-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升对方场上1只特殊召唤的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41209827,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c41209827.atkcon)
	e1:SetTarget(c41209827.atktg)
	e1:SetOperation(c41209827.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方场上1只5星以上的怪兽为对象才能发动。这张卡直到结束阶段得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41209827,1))  --"复制效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c41209827.copycost)
	e2:SetTarget(c41209827.copytg)
	e2:SetOperation(c41209827.copyop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被破坏的场合才能发动。对方场上的特殊召唤的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41209827,2))  --"全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c41209827.descon)
	e3:SetTarget(c41209827.destg)
	e3:SetOperation(c41209827.desop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：怪兽为暗属性、位于场上，且不是衍生物。
function c41209827.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsOnField() and not c:IsType(TYPE_TOKEN)
end
-- ①效果的发动条件：这张卡融合召唤成功。
function c41209827.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 攻击力上升效果选择对象的过滤条件：对方场上的表侧表示且通过特殊召唤出场的怪兽。
function c41209827.atkfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup()
end
-- 效果①的发动时点检测：确认对方场上存在至少1只符合条件的特殊召唤怪兽，以决定能否发动。
function c41209827.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在效果发动合法性检查阶段，则检索对方场上是否存在符合条件的表侧特殊召唤怪兽，以判定可否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41209827.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果①处理时：选择对方场上1只表侧表示的特殊召唤怪兽，将这张卡的攻击力上升该怪兽当前攻击力的数值，直到回合结束。
function c41209827.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示“请选择表侧表示的卡”的提示信息，用于后续选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示且特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c41209827.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		-- ①中‘这张卡的攻击力直到回合结束时上升对方场上1只特殊召唤的怪兽的攻击力数值’的规则实现：为这张卡注册攻击力上升效果，数值为所选怪兽的攻击力，到回合结束时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动代价：确认本回合没有发动过该效果；随后给这张卡设置标记，表示已使用过，直到结束阶段。
function c41209827.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(41209827)==0 end
	e:GetHandler():RegisterFlagEffect(41209827,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 复制效果选择对象的怪兽过滤条件：表侧表示、等级5以上且不是衍生物。
function c41209827.copyfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and not c:IsType(TYPE_TOKEN)
end
-- ②效果的目标选择：从对方场上选择1只表侧表示、5星以上且非衍生物的怪兽作为对象；该效果为取对象效果。
function c41209827.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c41209827.copyfilter(chkc) end
	-- 若在发动合法性阶段，检查对方场上是否存在符合条件的对象。
	if chk==0 then return Duel.IsExistingTarget(c41209827.copyfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只符合条件的怪兽，并将其设为效果的对象。
	Duel.SelectTarget(tp,c41209827.copyfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：令这张卡得到对象怪兽的原本卡名和效果（陷阱怪兽除外）；复制持续到结束阶段，并在结束阶段复原。具体通过修改卡名和复制效果实现。
function c41209827.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- ②中‘这张卡直到结束阶段得到和那只怪兽的原本的卡名…相同的卡名’：将该卡卡名改为对象怪兽的原本卡名，直到结束阶段。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		-- ②中‘直到结束阶段’的持续时间控制：在结束阶段触发复位，解除复制的卡名和效果。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(41209827,3))  --"结束复制效果"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c41209827.rstop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段时，解除这张卡因复制效果获得的卡名与效果（包括复制来的效果和变更的卡名），并向双方提示。
function c41209827.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 手动展示这张卡，令玩家注意到它已结束复制状态。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示‘结束复制效果’的发动/适用信息。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的发动条件：这张卡是融合召唤的怪兽，并且从场上被破坏。
function c41209827.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- ③破坏对象的过滤条件：特殊召唤的怪兽。
function c41209827.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ③效果的目标与操作信息：对方场上存在特殊召唤的怪兽时，登记要破坏的对象为对方场上所有特殊召唤的怪兽。
function c41209827.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动合法性阶段，检查对方场上是否存在至少1只特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41209827.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有特殊召唤的怪兽组。
	local g=Duel.GetMatchingGroup(c41209827.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 登记破坏效果的操作信息，指定破坏对象组及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ③效果处理时：将对方场上所有特殊召唤的怪兽破坏。
function c41209827.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有特殊召唤的怪兽组。
	local g=Duel.GetMatchingGroup(c41209827.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 以效果处理的名义破坏该怪兽组。
	Duel.Destroy(g,REASON_EFFECT)
end
