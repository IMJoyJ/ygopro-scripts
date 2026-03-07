--鎖付きブーメラン
-- 效果：
-- ①：从以下效果选择1个或者两方才能把这张卡发动。
-- ●对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那只攻击怪兽变成守备表示。
-- ●以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
function c37390589.initial_effect(c)
	-- 效果原文内容：①：从以下效果选择1个或者两方才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 规则层面作用：限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c37390589.target)
	e1:SetOperation(c37390589.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否满足发动条件，包括攻击宣言时的条件和装备效果的条件
function c37390589.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return false
		elseif e:GetLabel()==1 then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
		else return false end
	end
	-- 规则层面作用：检查是否为对方攻击宣言时点
	local b1=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and Duel.GetTurnPlayer()~=tp
		-- 规则层面作用：检查攻击怪兽是否在主要怪兽区且为攻击表示
		and Duel.GetAttacker():IsLocation(LOCATION_MZONE) and Duel.GetAttacker():IsAttackPos()
		-- 规则层面作用：检查攻击怪兽是否可以改变表示形式且能成为效果对象
		and Duel.GetAttacker():IsCanChangePosition() and Duel.GetAttacker():IsCanBeEffectTarget(e)
	local b2=e:IsCostChecked()
		-- 规则层面作用：检查自己场上是否存在表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=0
	if b1 and b2 then
		-- 规则层面作用：选择将攻击怪兽变为守备表示或装备卡效果
		opt=Duel.SelectOption(tp,aux.Stringid(37390589,0),aux.Stringid(37390589,1),aux.Stringid(37390589,2))  --"把攻击怪兽变成守备表示/变成装备卡/两个效果都使用"
	elseif b1 then
		-- 规则层面作用：选择将攻击怪兽变为守备表示
		opt=Duel.SelectOption(tp,aux.Stringid(37390589,0))  --"把攻击怪兽变成守备表示"
	else
		-- 规则层面作用：选择将怪兽装备为装备卡
		opt=Duel.SelectOption(tp,aux.Stringid(37390589,1))+1  --"变成装备卡"
	end
	if opt==0 or opt==2 then
		-- 规则层面作用：设置攻击怪兽为效果对象
		Duel.SetTargetCard(Duel.GetAttacker())
	end
	if opt==1 or opt==2 then
		if e:IsCostChecked() then
			local c=e:GetHandler()
			-- 规则层面作用：获取当前连锁ID
			local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
			-- 效果原文内容：●对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那只攻击怪兽变成守备表示。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_REMAIN_FIELD)
			e1:SetProperty(EFFECT_FLAG_OATH)
			e1:SetReset(RESET_CHAIN)
			c:RegisterEffect(e1)
			-- 效果原文内容：●以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_DISABLED)
			e2:SetOperation(c37390589.tgop)
			e2:SetLabel(cid)
			e2:SetReset(RESET_CHAIN)
			-- 规则层面作用：将效果注册给玩家
			Duel.RegisterEffect(e2,tp)
		end
		-- 规则层面作用：提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 规则层面作用：选择要装备的怪兽
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		-- 规则层面作用：设置效果操作信息为装备卡
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	end
	e:SetLabel(opt)
end
-- 规则层面作用：连锁被无效时的处理函数
function c37390589.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 规则层面作用：执行效果的处理逻辑
function c37390589.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	if opt==0 or opt==2 then
		-- 规则层面作用：获取当前攻击怪兽
		local tc=Duel.GetAttacker()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
			-- 规则层面作用：将攻击怪兽变为守备表示
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	end
	if opt==1 or opt==2 then
		if not c:IsLocation(LOCATION_SZONE) then return end
		if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
		local tc=e:GetLabelObject()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
			-- 规则层面作用：将装备卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 效果原文内容：这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			-- 效果原文内容：这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
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
-- 规则层面作用：限制装备卡只能装备给特定怪兽
function c37390589.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
