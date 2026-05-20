--CX 冀望皇バリアン
-- 效果：
-- 7星怪兽×3只以上
-- 这张卡也能在自己场上的「混沌No.101」～「混沌No.107」其中任意种的「混沌No.」怪兽上面重叠来超量召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
-- ②：以自己墓地1只「No.」怪兽为对象才能发动。直到对方结束阶段，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
function c67926903.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,c67926903.ovfilter,aux.Stringid(67926903,0),99)  --"是否要在自己场上的怪兽上面叠放来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c67926903.atkval)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只「No.」怪兽为对象才能发动。直到对方结束阶段，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67926903,1))  --"效果复制"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,67926903)
	e2:SetTarget(c67926903.copytg)
	e2:SetOperation(c67926903.copyop)
	c:RegisterEffect(e2)
end
-- 判定是否为自己场上用于重叠超量召唤的「混沌No.101」～「混沌No.107」怪兽。
function c67926903.ovfilter(c)
	-- 获取该怪兽的「No.」编号。
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(0x1048)
end
-- 计算并返回这张卡的超量素材数量×1000的数值。
function c67926903.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 过滤出墓地中属于「No.」系列且是效果怪兽的卡片。
function c67926903.filter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_EFFECT)
end
-- 复制效果的靶向/发动条件判定与对象选择。
function c67926903.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c67926903.filter(chkc) end
	-- 判定自己墓地是否存在可以作为对象的「No.」效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(c67926903.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只「No.」效果怪兽作为对象。
	Duel.SelectTarget(tp,c67926903.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 复制效果的执行处理，使这张卡获得目标怪兽的原本卡名和效果，并注册回合结束时的重置效果。
function c67926903.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- 直到对方结束阶段，这张卡得到和那只怪兽的原本的卡名·效果相同的卡名·效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(code)
		e1:SetLabel(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 直到对方结束阶段
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(67926903,2))  --"复制效果结束"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(c67926903.rstcon)
		e2:SetOperation(c67926903.rstop)
		e2:SetLabel(cid)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
end
-- 判定重置条件，即当前回合玩家不是发动效果的玩家（即对方回合）。
function c67926903.rstcon(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	-- 判定当前回合玩家是否为对方玩家。
	return Duel.GetTurnPlayer()~=e1:GetLabel()
end
-- 执行重置操作，还原这张卡的原本卡名，并清除复制的效果。
function c67926903.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 闪烁显示这张卡，提示玩家该卡发生了状态变化（重置效果）。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“复制效果结束”。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
