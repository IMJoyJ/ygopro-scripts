--パワー・フレーム
-- 效果：
-- 自己场上表侧表示存在的怪兽被选择作为持有比那个攻击力高的攻击力的怪兽的攻击对象时才能发动。那次攻击无效，这张卡给1只攻击对象怪兽装备。装备怪兽的攻击力上升那个时候的攻击怪兽和攻击对象怪兽的攻击力差的数值。
function c53656677.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽被选择作为持有比那个攻击力高的攻击力的怪兽的攻击对象时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCost(c53656677.cost)
	e1:SetTarget(c53656677.target)
	e1:SetOperation(c53656677.operation)
	c:RegisterEffect(e1)
end
-- 设置cost函数，用于处理发动时的费用
function c53656677.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这次攻击无效，这张卡给1只攻击对象怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个连锁被无效时触发的效果，用于防止卡牌被送入墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c53656677.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，取消将卡牌送入墓地的操作
function c53656677.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 判断目标怪兽是否满足发动条件
function c53656677.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置目标为当前攻击对象怪兽
	if chkc then return chkc==Duel.GetAttackTarget() end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(tp) and d:IsFaceup() and d:IsCanBeEffectTarget(e)
		and d:GetAttack()<a:GetAttack() and e:IsCostChecked() end
	-- 设置攻击对象怪兽为连锁对象
	Duel.SetTargetCard(d)
end
-- 执行效果的主要操作，包括无效攻击、装备怪兽并增加攻击力
function c53656677.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取连锁对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 获取攻击怪兽
		local a=Duel.GetAttacker()
		-- 获取攻击对象怪兽
		local d=Duel.GetAttackTarget()
		local atk=a:GetAttack()-d:GetAttack()
		if atk<0 then atk=0 end
		-- 装备怪兽的攻击力上升那个时候的攻击怪兽和攻击对象怪兽的攻击力差的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备限制，确保只有指定怪兽能装备此卡
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c53656677.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabelObject(tc)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 判断装备对象是否为指定怪兽
function c53656677.eqlimit(e,c)
	return c==e:GetLabelObject()
end
