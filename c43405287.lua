--D－チェーン
-- 效果：
-- ①：以自己场上1只「命运英雄」怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
-- ②：装备怪兽战斗破坏对方怪兽送去墓地的场合发动。给与对方500伤害。
function c43405287.initial_effect(c)
	-- ①：以自己场上1只「命运英雄」怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设定效果的发动条件：只能在伤害步骤的伤害计算前发动（不能进入伤害计算后发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c43405287.cost)
	e1:SetTarget(c43405287.target)
	e1:SetOperation(c43405287.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽战斗破坏对方怪兽送去墓地的场合发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43405287,0))  --"伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c43405287.damcon)
	e2:SetTarget(c43405287.damtg)
	e2:SetOperation(c43405287.damop)
	c:RegisterEffect(e2)
end
-- 发动时的代价处理：不支付实际代价，而是为此卡附加发动后留在场上的誓约效果，并注册连锁被无效时取消送墓的辅助效果，以保证此卡作为装备卡继续留在场上。
function c43405287.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁的唯一ID，用于后续识别该连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只「命运英雄」怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c43405287.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将创建的连续效果以当前玩家tp为控制者注册到游戏中，用于监听本卡发动所在连锁被无效的事件。
	Duel.RegisterEffect(e2,tp)
end
-- 当本卡发动被无效时，若此卡仍与该连锁相关，则取消其被送去墓地的处理，使其继续留在场上。
function c43405287.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，与之前记录的本卡发动连锁ID比较，以确认确实是本卡的发动被无效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：卡为表侧表示且属于「命运英雄」字段（0xc008）。
function c43405287.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 效果目标合法性检查：对已选对象确认其为自己场上表侧表示的「命运英雄」怪兽；发动时确认已经满足代价条件且场上存在符合条件的装备对象。
function c43405287.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c43405287.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只表侧表示的「命运英雄」怪兽，以确保可以选取装备对象。
		and Duel.IsExistingTarget(c43405287.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的UI提示，用于下一步选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只符合条件的「命运英雄」怪兽，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c43405287.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息，声明本效果为装备分类（CATEGORY_EQUIP），涉及的卡为这张卡自身，数量为1，供其他效果响应和判定。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍在魔陷区、与效果关联且装备目标仍合法，则将其装备给目标怪兽，并赋予攻击力+500和装备限制效果；否则此卡送去墓地。
function c43405287.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得发动时选择的目标怪兽（即装备对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张卡作为装备卡装备到目标怪兽的魔陷区（怪兽身上）。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给那只自己怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c43405287.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 定义装备限制：只有当前装备目标或己方场上的「命运英雄」怪兽可以装备此卡。
function c43405287.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0xc008)
end
-- 过滤条件：判断怪兽是否因被装备怪兽战斗破坏而送去墓地：位于墓地、破坏原因为战斗、且破坏者为装备怪兽。
function c43405287.damfilter(c,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc
end
-- 伤害效果发动条件：装备怪兽存在，且本次战斗破坏的怪兽中有满足damfilter的对方怪兽（即装备怪兽战斗破坏的怪兽）。
function c43405287.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and eg:IsExists(c43405287.damfilter,1,nil,tc)
end
-- 伤害效果的目标设定：不取对象，直接将对方玩家设为受到伤害的对象，伤害值为500，并登记伤害操作信息。
function c43405287.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家（1-tp），即承受伤害的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为500，作为要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 设置操作信息，声明本效果将造成伤害（CATEGORY_DAMAGE），目标为对方玩家，数值为500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果处理：从连锁信息中读取对象玩家和伤害数值，对对方造成500点效果伤害。
function c43405287.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的要受到伤害的玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定数值的效果伤害，并触发相关时点与连锁。
	Duel.Damage(p,d,REASON_EFFECT)
end
