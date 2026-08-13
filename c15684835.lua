--イービル・ブラスト
-- 效果：
-- 对方场上有怪兽特殊召唤时才能发动。发动后，变成攻击力上升500的装备卡，给那只怪兽装备。每次对方回合的准备阶段给与对方基本分500分伤害。
function c15684835.initial_effect(c)
	-- 对方场上有怪兽特殊召唤时才能发动。发动后，变成攻击力上升500的装备卡，给那只怪兽装备。每次对方回合的准备阶段给与对方基本分500分伤害。
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
-- 发动代价：将此卡标记为发动后留在场上（不会被规则送墓），并注册一个当本次连锁被无效时取消送墓的辅助效果，以确保后续能装备给怪兽。
function c15684835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，作为本次发动行为的唯一标识，供后续判断连锁是否被无效时使用。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后，变成攻击力上升500的装备卡，给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上有怪兽特殊召唤时才能发动。发动后，变成攻击力上升500的装备卡，给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c15684835.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁无效保护效果注册到场上，使其在本连锁被无效时能触发补救处理。
	Duel.RegisterEffect(e2,tp)
end
-- 当本次连锁被无效时，若此卡仍与该连锁相关，则解除其‘连锁处理完后送去墓地’的确定状态，让它保留在场上。
function c15684835.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被无效的那个连锁的ID，与本次发动记录的ID比对，确认是本次发动被无效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选条件：怪兽必须是表侧表示、在对方场上，并且能够成为本效果的对象。
function c15684835.filter(c,e,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:IsCanBeEffectTarget(e)
end
-- 发动合法性检查：cost已支付且特殊召唤的怪兽中存在可装备的对象；连锁选择对象时，确认所选怪兽在特殊召唤组中且满足筛选条件。
function c15684835.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c15684835.filter(chkc,e,tp) end
	if chk==0 then return e:IsCostChecked()
		and eg:IsExists(c15684835.filter,1,nil,e,tp) end
	-- 提示玩家选择一张要装备的怪兽（装备对象选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	local g=eg:FilterSelect(tp,c15684835.filter,1,1,nil,e,tp)
	-- 将选中的怪兽设置为当前连锁的对象（取对象）。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本效果将把发动者自身作为装备卡装备给对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍在魔法陷阱区且与效果关联，则将对象怪兽取出，若对象仍关联且表侧，则把此卡装备给对象，并赋予准备阶段伤害、攻击力上升500和装备限制；否则将此卡送去墓地。
function c15684835.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的对象怪兽，即要装备的目标。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备到对象怪兽身上。
		Duel.Equip(tp,c,tc)
		-- 每次对方回合的准备阶段给与对方基本分500分伤害。
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
		-- 攻击力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给那只怪兽装备。
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
-- 装备限制函数：装备对象只能是当初选择的那只怪兽。
function c15684835.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 伤害效果的发动条件：必须是对方回合的准备阶段。
function c15684835.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是此卡控制者（即处于对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 伤害效果发动时：确定伤害对象为对方玩家，伤害数值为500，并设置伤害操作信息。
function c15684835.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将伤害对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值参数设置为500。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本次效果会对对方造成500点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害处理：读取记录的对象玩家和伤害值，实际执行效果伤害。
function c15684835.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中读取目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
