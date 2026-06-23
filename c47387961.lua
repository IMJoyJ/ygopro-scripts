--No.8 紋章王ゲノム・ヘリター
-- 效果：
-- 4星「纹章兽」怪兽×2
-- ①：1回合1次，以对方场上1只超量怪兽为对象才能发动。这张卡原本攻击力变成和那只怪兽的攻击力相同，得到和那只怪兽的原本的卡名·效果相同的卡名·效果。那之后，作为对象的怪兽的攻击力变成0，效果无效化。这个效果直到结束阶段适用。
function c47387961.initial_effect(c)
	-- 为卡片添加等级为4、需要2只「纹章兽」怪兽的XYZ召唤手续
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
-- 设置该卡为No.8系列怪兽
aux.xyz_number[47387961]=8
-- 过滤函数：判断目标是否为表侧表示的超量怪兽
function c47387961.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置效果的目标选择处理，选择对方场上的1只表侧表示的超量怪兽作为对象
function c47387961.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c47387961.filter(chkc) end
	-- 检查是否有满足条件的超量怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(c47387961.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的一只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c47387961.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果发动时的处理函数，包括复制目标怪兽的卡名和攻击力，并使目标怪兽攻击力变为0且效果无效化
function c47387961.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 将自身卡名替换为与目标怪兽相同的原始卡名
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
		-- 将目标怪兽的攻击力设置为0
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
		e1:SetLabelObject(e2)
		e2:SetLabelObject(e4)
		-- 判断目标怪兽是否可以被无效化
		if aux.NegateMonsterFilter(tc) then
			-- 使目标怪兽的效果无效
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_DISABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e5)
			-- 使目标怪兽的效果无效化（持续效果）
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_DISABLE_EFFECT)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e6)
			e4:SetLabelObject(e5)
			e5:SetLabelObject(e6)
		end
		-- 注册一个在结束阶段触发的效果，用于清除复制效果和相关状态
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
-- 结束阶段时清除复制效果及相关的状态
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
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
