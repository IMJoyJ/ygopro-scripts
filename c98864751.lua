--エアークラック・ストーム
-- 效果：
-- 机械族怪兽才能装备。
-- ①：装备怪兽的攻击破坏对方怪兽时才能发动。这次战斗阶段中，装备怪兽只再1次可以攻击。这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
function c98864751.initial_effect(c)
	-- 机械族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c98864751.target)
	e1:SetOperation(c98864751.operation)
	c:RegisterEffect(e1)
	-- 机械族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c98864751.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击破坏对方怪兽时才能发动。这次战斗阶段中，装备怪兽只再1次可以攻击。这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98864751,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c98864751.drcon)
	e3:SetCost(c98864751.cost)
	e3:SetOperation(c98864751.drop)
	c:RegisterEffect(e3)
	if not c98864751.global_check then
		c98864751.global_check=true
		c98864751[0]=0
		c98864751[1]=0
		-- 这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c98864751.checkop)
		-- 注册全局效果，用于在怪兽进行攻击宣言时记录攻击信息。
		Duel.RegisterEffect(ge1,0)
		-- 这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c98864751.clear)
		-- 注册全局效果，在每个回合开始时重置攻击宣言的计数。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 攻击宣言时的操作，记录进行过攻击宣言的怪兽，并增加对应玩家的攻击怪兽计数。
function c98864751.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:GetFlagEffect(98864751)==0 then
		c98864751[ep]=c98864751[ep]+1
		tc:RegisterFlagEffect(98864751,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 回合开始时的清理操作，将双方玩家的攻击怪兽计数重置为0。
function c98864751.clear(e,tp,eg,ep,ev,re,r,rp)
	c98864751[0]=0
	c98864751[1]=0
end
-- 装备限制判定，此卡只能装备给机械族怪兽。
function c98864751.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 过滤场上表侧表示的机械族怪兽。
function c98864751.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 装备魔法卡发动时的效果目标选择与处理。
function c98864751.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c98864751.eqfilter(chkc) end
	-- 检查场上是否存在可以装备的合法机械族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c98864751.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择场上1只表侧表示的机械族怪兽作为装备对象并将其设为效果对象。
	Duel.SelectTarget(tp,c98864751.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含装备卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，将此卡装备给选择的对象怪兽。
function c98864751.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将当前卡片作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果①的发动条件判定，装备怪兽通过战斗破坏对方怪兽。
function c98864751.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return e:GetHandler():GetEquipTarget()==ec and ec:GetBattleTarget():IsReason(REASON_BATTLE)
end
-- 效果①的发动代价与限制处理，检查本回合是否有其他怪兽攻击过，并适用“其他怪兽不能攻击”的限制。
function c98864751.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c98864751[tp]==0 or c:GetEquipTarget():GetFlagEffect(98864751)~=0 end
	-- 这个效果发动的回合，装备怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c98864751.ftarget)
	e1:SetLabel(c:GetEquipTarget():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“除装备怪兽以外的自己怪兽不能攻击”的限制效果给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制攻击的目标过滤，用于排除装备怪兽本身。
function c98864751.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果①的效果处理，使装备怪兽在本次战斗阶段中可以再进行1次攻击。
function c98864751.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 这次战斗阶段中，装备怪兽只再1次可以攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	e:GetHandler():GetEquipTarget():RegisterEffect(e1)
end
