--隷属の鱗粉
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。攻击怪兽的表示形式变成守备表示，那1只怪兽把这张卡装备。此外，1回合1次，主要阶段以及战斗阶段时才能发动。装备怪兽的表示形式变更。
function c75987257.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。攻击怪兽的表示形式变成守备表示，那1只怪兽把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c75987257.condition)
	e1:SetCost(c75987257.cost)
	e1:SetTarget(c75987257.target)
	e1:SetOperation(c75987257.operation)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，主要阶段以及战斗阶段时才能发动。装备怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75987257,0))  --"变更表示形式"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c75987257.poscon)
	e2:SetOperation(c75987257.posop)
	c:RegisterEffect(e2)
end
-- 定义发动条件函数：检查是否为对方回合的攻击宣言
function c75987257.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不是自己
	return Duel.GetTurnPlayer()~=tp
end
-- 定义发动代价函数：处理陷阱卡发动后留在场上的状态，并注册连锁无效时的处理效果
function c75987257.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 那1只怪兽把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时才能发动。攻击怪兽的表示形式变成守备表示，那1只怪兽把这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c75987257.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁无效时的处理效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 定义连锁无效时的处理函数：若本卡的发动被无效，则取消留在场上的状态并正常送去墓地
function c75987257.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该事件的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义效果对象选择函数：选择进行攻击宣言的怪兽为效果对象
function c75987257.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsLocation(LOCATION_MZONE) and tc:IsAttackPos()
		and tc:IsCanChangePosition() and tc:IsCanBeEffectTarget(e) and e:IsCostChecked() end
	-- 将攻击怪兽设为当前连锁的效果对象
	Duel.SetTargetCard(tc)
end
-- 定义效果处理函数：将攻击怪兽变成守备表示，并将这张卡装备给该怪兽
function c75987257.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 将目标怪兽变更为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡作为装备卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 那1只怪兽把这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(c75987257.eqlimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 定义装备限制函数：限制这张卡只能装备给作为效果对象的那只怪兽
function c75987257.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 定义变更表示形式效果的发动条件函数：必须在主要阶段或战斗阶段，且自身已装备怪兽
function c75987257.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2 and e:GetHandler():GetEquipTarget()
end
-- 定义变更表示形式效果的处理函数：变更装备怪兽的表示形式
function c75987257.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec then
		-- 将装备怪兽的表示形式变更（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
