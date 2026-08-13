--使い捨て学習装置
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升自己墓地的怪兽数量×200。
-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c42149850.initial_effect(c)
	-- ①：装备怪兽的攻击力上升自己墓地的怪兽数量×200。（该段实现装备魔法的发动并装备给怪兽）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42149850.target)
	e1:SetOperation(c42149850.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升自己墓地的怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c42149850.atkval)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的回合的结束阶段才能发动。（此处登记从场上送去墓地的标记）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c42149850.regcon)
	e3:SetOperation(c42149850.regop)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从场上送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42149850,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,42149850)
	e4:SetCondition(c42149850.setcon)
	e4:SetTarget(c42149850.settg)
	e4:SetOperation(c42149850.setop)
	c:RegisterEffect(e4)
	-- 装备怪兽（①中“装备怪兽的攻击力上升……”的装备对象限制为怪兽）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 发动时的目标选择：从双方场上选择1只表侧表示怪兽作为装备对象，并设置装备操作信息。
function c42149850.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件判定：确认场上是否存在至少1只表侧表示怪兽可供选择作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上表侧表示怪兽作为装备对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为装备类别，对象为本卡，数量为1，供后续处理时确定装备操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备操作：确认本卡与对象怪兽仍与效果关联且对象为表侧表示后，将本卡装备给对象怪兽。
function c42149850.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将本卡作为装备卡装备给对象怪兽（装备成功则本卡进入魔法陷阱区并适用装备效果）。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算攻击力上升值的函数：根据自己墓地的怪兽数量决定装备怪兽的攻击力上升数值。
function c42149850.atkval(e,c)
	-- 返回自己墓地中怪兽卡数量乘以200的数值，作为装备怪兽的攻击力上升量。
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)*200
end
-- 判定条件：本卡从场上被送去墓地（即原所在位置为场上）时才满足登记条件。
function c42149850.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 登记②效果可发动的标记：给本卡设置一个持续到结束阶段的flag，表示本回合从场上送入墓地。
function c42149850.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(42149850,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判定②效果能否发动：检查本卡是否拥有从场上送去墓地时登记的flag（即本回合确实从场上进入墓地）。
function c42149850.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(42149850)>0
end
-- ②效果发动时的条件与操作信息设置：确认本卡可以盖放，并设置涉及墓地的操作信息。
function c42149850.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 将本卡从墓地离开（盖放到场上）的操作信息登记为涉及墓地的类别，用于相关效果的连锁检测（如王家长眠之谷）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：将本卡在自己场上盖放；若成功，再附加一个离场时除外代替去墓地的效果。
function c42149850.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行盖放操作；若盖放成功（返回非0）才追加除外效果。
		if Duel.SSet(tp,c)~=0 then
			-- 这个效果盖放的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end
