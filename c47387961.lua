--No.8 紋章王ゲノム・ヘリター
-- 效果：
-- 4星「纹章兽」怪兽×2
-- ①：1回合1次，以对方场上1只超量怪兽为对象才能发动。这张卡原本攻击力变成和那只怪兽的攻击力相同，得到和那只怪兽的原本的卡名·效果相同的卡名·效果。那之后，作为对象的怪兽的攻击力变成0，效果无效化。这个效果直到结束阶段适用。
function c47387961.initial_effect(c)
	-- 为这张卡添加超量召唤手续，对应召唤条件“4星「纹章兽」怪兽×2”：需要2只等级4且卡名属于「纹章兽」系列的怪兽作为超量素材。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x76),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，以对方场上1只超量怪兽为对象才能发动。这张卡原本攻击力变成和那只怪兽的攻击力相同，得到和那只怪兽的原本的卡名·效果相同的卡名·效果。那之后，作为对象的怪兽的攻击力变成0，效果无效化。这个效果直到结束阶段适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(47387961,0))  --"获得效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c47387961.target)
	e1:SetOperation(c47387961.operation)
	c:RegisterEffect(e1)
end
-- 将这张卡的卡号登记进XYZ编号表，作为“No.8”供No.相关规则和效果识别。
aux.xyz_number[47387961]=8
-- 定义对象筛选条件：卡片需为表侧表示的超量怪兽。
function c47387961.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 处理效果发动时的对象指定：校验指定对象必须是对方场上表侧表示的超量怪兽；若无指定对象且存在合法目标，则让玩家选择1只作为对象。
function c47387961.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c47387961.filter(chkc) end
	-- 效果发动合法性检查：确认对方场上存在至少1只可被选择为对象的表侧表示超量怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c47387961.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示超量怪兽，并将其登记为本次效果的对象。
	Duel.SelectTarget(tp,c47387961.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若此卡与对象怪兽仍相关联且均表侧表示，则复制对象怪兽的原本卡名与原本效果，将此卡原本攻击力变成对象怪兽当前攻击力，将对象怪兽攻击力变成0并无效其效果，并安排结束阶段解除这些效果。
function c47387961.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果发动时选择的对象怪兽（对方场上表侧表示的超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 得到和那只怪兽的原本的卡名·效果相同的卡名·效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetOriginalCodeRule())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
		local cid=c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 作为对象的怪兽的攻击力变成0
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
		e1:SetLabelObject(e2)
		e2:SetLabelObject(e4)
		-- 判断对象怪兽是否为表侧表示且未被无效的效果怪兽（或原本是效果怪兽），决定是否对其适用“效果无效化”。
		if aux.NegateMonsterFilter(tc) then
			-- 效果无效化
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_DISABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e5)
			-- 效果无效化
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_DISABLE_EFFECT)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e6)
			e4:SetLabelObject(e5)
			e5:SetLabelObject(e6)
		end
		-- 这个效果直到结束阶段适用
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(aux.Stringid(47387961,1))  --"结束复制效果"
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_PHASE+PHASE_END)
		e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e7:SetCountLimit(1)
		e7:SetRange(LOCATION_MZONE)
		e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e7:SetLabel(cid)
		e7:SetLabelObject(e1)
		e7:SetOperation(c47387961.rstop)
		c:RegisterEffect(e7)
	end
end
-- 结束阶段处理：解除复制来的效果、卡名/攻击力变化以及无效化等效果，使此卡和对象怪兽恢复原状，并提示玩家复制结束。
function c47387961.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	local e2=e1:GetLabelObject()
	local e4=e2:GetLabelObject()
	local e5=e4:GetLabelObject()
	e1:Reset()
	e2:Reset()
	e4:Reset()
	if e5 then
		local e6=e5:GetLabelObject()
		e5:Reset()
		e6:Reset()
	end
	-- 手动展示此卡被选中/解除复制的动画，向双方显示这张卡。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示此效果已结束（“对方选择了：结束复制效果”）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
