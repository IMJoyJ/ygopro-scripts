--イービル・ブラスト
-- 效果：
-- 对方场上有怪兽特殊召唤时才能发动。发动后，变成攻击力上升500的装备卡，给那只怪兽装备。每次对方回合的准备阶段给与对方基本分500分伤害。
function c15684835.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，连锁时点为对方怪兽特殊召唤成功，需要选择对象，设置费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c15684835.cost)
	e1:SetTarget(c15684835.target)
	e1:SetOperation(c15684835.operation)
	c:RegisterEffect(e1)
end
-- 费用函数，检查是否满足发动条件，设置卡牌在场上停留的效果和连锁被无效时的处理效果
function c15684835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置卡牌在场上停留的效果，防止被送入墓地
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 创建连锁被无效时的处理效果，用于防止卡牌被送入墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c15684835.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时的处理效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，如果当前效果与被无效的连锁匹配，则取消送入墓地
function c15684835.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤函数，筛选对方场上正面表示的怪兽
function c15684835.filter(c,e,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:IsCanBeEffectTarget(e)
end
-- 目标选择函数，检查是否有符合条件的怪兽可作为目标
function c15684835.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c15684835.filter(chkc,e,tp) end
	if chk==0 then return e:IsCostChecked()
		and eg:IsExists(c15684835.filter,1,nil,e,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	local g=eg:FilterSelect(tp,c15684835.filter,1,1,nil,e,tp)
	-- 设置当前效果的目标怪兽
	Duel.SetTargetCard(g)
	-- 设置效果操作信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数，检查装备条件并执行装备操作
function c15684835.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 创建每次对方回合准备阶段触发的伤害效果
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(15684835,0))  --"伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetCondition(c15684835.damcon)
		e1:SetTarget(c15684835.damtg)
		e1:SetOperation(c15684835.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 创建装备卡攻击力上升500的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 创建装备限制效果，只能装备给特定怪兽
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c15684835.eqlimit)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制函数，判断是否可以装备给指定怪兽
function c15684835.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 伤害触发条件函数，判断是否为对方回合
function c15684835.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动者
	return Duel.GetTurnPlayer()~=tp
end
-- 伤害效果目标函数，设置伤害对象和伤害值
function c15684835.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为500
	Duel.SetTargetParam(500)
	-- 设置效果操作信息，表示将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果处理函数，对指定玩家造成伤害
function c15684835.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取伤害对象和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
