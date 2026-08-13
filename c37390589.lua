--鎖付きブーメラン
-- 效果：
-- ①：从以下效果选择1个或者两方才能把这张卡发动。
-- ●对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那只攻击怪兽变成守备表示。
-- ●以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
function c37390589.initial_effect(c)
	-- ①：从以下效果选择1个或者两方才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果的发动条件为aux.dscon，即仅在非伤害步骤或伤害步骤的伤害计算前可以发动，避免在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c37390589.target)
	e1:SetOperation(c37390589.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与合法条件检测函数：根据当前时点和场上情况判断可选分支，让玩家选择使用的效果，并选择/标记对应对象。
function c37390589.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return false
		elseif e:GetLabel()==1 then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		else return false end
	end
	-- 检测当前时点是否为对方回合的攻击宣言，且攻击者为对方怪兽，以满足第一个分支的发动前提。
	local b1=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and Duel.GetTurnPlayer()~=tp
		-- 确认攻击怪兽位于怪兽区域且为攻击表示，符合可被变更为守备表示的条件。
		and Duel.GetAttacker():IsLocation(LOCATION_MZONE) and Duel.GetAttacker():IsAttackPos()
		-- 确认攻击怪兽能够变更表示形式且能够成为这张卡的效果对象。
		and Duel.GetAttacker():IsCanChangePosition() and Duel.GetAttacker():IsCanBeEffectTarget(e)
	local b2=e:IsCostChecked()
		-- 确认自己场上存在至少1只表侧表示怪兽，可以作为装备卡的目标。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=0
	if b1 and b2 then
		-- 当两个分支都可用时，为发动者显示三个选项：把攻击怪兽变成守备表示、变成装备卡、两个效果都使用。
		opt=Duel.SelectOption(tp,aux.Stringid(37390589,0),aux.Stringid(37390589,1),aux.Stringid(37390589,2))  --"把攻击怪兽变成守备表示/变成装备卡/两个效果都使用"
	elseif b1 then
		-- 当只有攻击怪兽效果可用时，显示选项：把攻击怪兽变成守备表示。
		opt=Duel.SelectOption(tp,aux.Stringid(37390589,0))  --"把攻击怪兽变成守备表示"
	else
		-- 当只有装备效果可用时，显示选项：变成装备卡；+1是因为SelectOption返回值从0开始，这里需要映射到1（装备模式）。
		opt=Duel.SelectOption(tp,aux.Stringid(37390589,1))+1  --"变成装备卡"
	end
	if opt==0 or opt==2 then
		-- 将当前攻击怪兽设置为这张卡的效果对象（取对象），用于后续将其变更为守备表示。
		Duel.SetTargetCard(Duel.GetAttacker())
	end
	if opt==1 or opt==2 then
		if e:IsCostChecked() then
			local c=e:GetHandler()
			-- 获取当前连锁的连锁ID，用于后续监测该连锁是否被无效。
			local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
			-- 以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_REMAIN_FIELD)
			e1:SetProperty(EFFECT_FLAG_OATH)
			e1:SetReset(RESET_CHAIN)
			c:RegisterEffect(e1)
			-- 以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_DISABLED)
			e2:SetOperation(c37390589.tgop)
			e2:SetLabel(cid)
			e2:SetReset(RESET_CHAIN)
			-- 在效果发动方场上注册一个持续效果，监测当前连锁是否被无效；若被无效则执行tgop处理，防止装备卡因连锁无效而滞留墓地的错误情况。
			Duel.RegisterEffect(e2,tp)
		end
		-- 给发动者显示‘请选择要装备的卡’的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己场上选择1只表侧表示怪兽作为装备对象，并将其作为效果对象记录。
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		-- 设置操作信息，声明本连锁将进行装备（CATEGORY_EQUIP），处理时此卡会成为装备卡。
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	end
	e:SetLabel(opt)
end
-- tgop函数：当被监测的连锁被无效时，若这张卡仍与该连锁关联，则取消其送去墓地的处理，使其留在应有的位置。
function c37390589.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的连锁ID，与保存的标签比较以确认是本连锁被无效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- operation函数：效果实际处理时，根据发动时选择的模式处理：若为攻击怪兽效果，则攻击怪兽变守备；若为装备效果，则将此卡装备给选择的目标并赋予攻击力上升500。
function c37390589.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	if opt==0 or opt==2 then
		-- 获取当前攻击怪兽，用于执行将其变为守备表示的处理。
		local tc=Duel.GetAttacker()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
			-- 将攻击怪兽变更为表侧守备表示。
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	end
	if opt==1 or opt==2 then
		if not c:IsLocation(LOCATION_SZONE) then return end
		if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
		local tc=e:GetLabelObject()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
			-- 将此卡作为装备卡装备给选择的目标怪兽，使其成为装备魔法卡。
			Duel.Equip(tp,c,tc)
			-- 攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			-- 给那只自己怪兽装备。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(c37390589.eqlimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		else
			c:CancelToGrave(false)
		end
	end
end
-- eqlimit函数：装备限制条件，返回true表示允许装备；条件为：这张卡当前装备的对象是这只怪兽，或这只怪兽的控制者是自己（即只能装备给自己场上的怪兽）。
function c37390589.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
