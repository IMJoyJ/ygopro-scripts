--パワー・フレーム
-- 效果：
-- 自己场上表侧表示存在的怪兽被选择作为持有比那个攻击力高的攻击力的怪兽的攻击对象时才能发动。那次攻击无效，这张卡给1只攻击对象怪兽装备。装备怪兽的攻击力上升那个时候的攻击怪兽和攻击对象怪兽的攻击力差的数值。
function c53656677.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽被选择作为持有比那个攻击力高的攻击力的怪兽的攻击对象时才能发动。那次攻击无效，这张卡给1只攻击对象怪兽装备。装备怪兽的攻击力上升那个时候的攻击怪兽和攻击对象怪兽的攻击力差的数值。
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
-- 发动代价：无条件通过；同时给此卡附加连锁处理期间留在场上的誓约效果，并注册‘连锁被无效时取消送墓’的辅助效果，为后续装备做准备。
function c53656677.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的编号，用于后续判断当前连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡给1只攻击对象怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 那次攻击无效，这张卡给1只攻击对象怪兽装备。装备怪兽的攻击力上升那个时候的攻击怪兽和攻击对象怪兽的攻击力差的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c53656677.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监测连锁被无效的持续效果e2注册到场上，该效果由tp控制，用于检测当前连锁被无效时让此卡取消送墓。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的辅助处理：若被无效的连锁编号与此卡发动时的连锁一致，且此卡仍与该连锁相关，则取消此卡被送去墓地的处理。
function c53656677.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被无效的连锁的编号，与之前保存的本连锁编号比较。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 取对象效果的目标选择：选择自己场上表侧表示、可成为效果对象、且攻击力低于攻击怪兽攻击力的攻击对象怪兽作为对象，同时确认cost已满足。
function c53656677.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在连锁处理前核对已选对象时，只允许选择当时的攻击对象怪兽。
	if chkc then return chkc==Duel.GetAttackTarget() end
	-- 获取发动效果时正在攻击的怪兽（攻击怪兽）。
	local a=Duel.GetAttacker()
	-- 获取被选为攻击对象的怪兽。
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(tp) and d:IsFaceup() and d:IsCanBeEffectTarget(e)
		and d:GetAttack()<a:GetAttack() and e:IsCostChecked() end
	-- 将被攻击的怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(d)
end
-- 效果处理：无效那次攻击；若此卡仍在场上且效果有效，则将此卡装备给对象怪兽，并根据攻击怪兽与对象怪兽的攻击力差值上升装备怪兽的攻击力；若对象不合适则此卡送去墓地。
function c53656677.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 无效这次攻击。
	Duel.NegateAttack()
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得效果对象（被攻击的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 在装备后重新获取攻击怪兽，用于计算攻击力差。
		local a=Duel.GetAttacker()
		-- 在装备后重新获取攻击对象怪兽，用于计算攻击力差。
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
		-- 这张卡给1只攻击对象怪兽装备。
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
-- 装备限制判定函数：仅当目标卡与记录的对象一致时允许装备，保证此卡只装备给当时的攻击对象怪兽。
function c53656677.eqlimit(e,c)
	return c==e:GetLabelObject()
end
