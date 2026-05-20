--生存競争
-- 效果：
-- ①：以自己场上1只恐龙族怪兽为对象才能把这张卡发动。这张卡当作攻击力上升1000的装备卡使用给那只自己的恐龙族怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽攻击破坏对方怪兽送去墓地时才能发动。装备怪兽向对方怪兽只再1次可以继续攻击。
function c58272005.initial_effect(c)
	-- ①：以自己场上1只恐龙族怪兽为对象才能把这张卡发动。这张卡当作攻击力上升1000的装备卡使用给那只自己的恐龙族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件：在伤害步骤中，仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c58272005.cost)
	e1:SetTarget(c58272005.target)
	e1:SetOperation(c58272005.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost：处理通常陷阱发动后留在场上的规则，并注册连锁被无效时的处理
function c58272005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- ①：以自己场上1只恐龙族怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只恐龙族怪兽为对象才能把这张卡发动。这张卡当作攻击力上升1000的装备卡使用给那只自己的恐龙族怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c58272005.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果：用于在连锁被无效时将此卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：取消“留在场上”的状态，使其正常送去墓地
function c58272005.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：自己场上表侧表示的恐龙族怪兽
function c58272005.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 效果发动的目标选择与合法性检测
function c58272005.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c58272005.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示恐龙族怪兽
		and Duel.IsExistingTarget(c58272005.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的恐龙族怪兽作为对象
	Duel.SelectTarget(tp,c58272005.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息：表明此效果包含装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给目标怪兽，并赋予攻击力上升和连续攻击的效果
function c58272005.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_DINOSAUR) then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作攻击力上升1000的装备卡使用给那只自己的恐龙族怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作攻击力上升1000的装备卡使用给那只自己的恐龙族怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c58272005.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- ②：用这张卡的效果把这张卡装备的怪兽攻击破坏对方怪兽送去墓地时才能发动。装备怪兽向对方怪兽只再1次可以继续攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(58272005,0))  --"连续攻击"
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCode(EVENT_BATTLE_DESTROYING)
		e3:SetCondition(c58272005.atcon)
		e3:SetOperation(c58272005.atop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给自身场上的恐龙族怪兽
function c58272005.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_DINOSAUR)
end
-- 连续攻击效果的发动条件：装备怪兽通过战斗将对方怪兽破坏并送去墓地，且该怪兽仍能进行攻击
function c58272005.atcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not eg:IsContains(ec) then return false end
	local bc=ec:GetBattleTarget()
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and ec:IsChainAttackable(2,true) and ec:IsStatus(STATUS_OPPO_BATTLE)
end
-- 连续攻击效果的处理：使装备怪兽可以再进行1次攻击，并限制其不能直接攻击
function c58272005.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	-- 使装备怪兽可以再进行1次攻击
	Duel.ChainAttack()
	-- 装备怪兽向对方怪兽只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	ec:RegisterEffect(e1)
end
