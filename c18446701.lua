--ガガガシールド
-- 效果：
-- ①：以自己场上1只魔法师族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。装备怪兽1回合最多2次不会被战斗·效果破坏。
function c18446701.initial_effect(c)
	-- ①：以自己场上1只魔法师族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c18446701.cost)
	e1:SetTarget(c18446701.target)
	e1:SetOperation(c18446701.operation)
	c:RegisterEffect(e1)
end
-- 发动时无实际COST；记录当前连锁ID，给自己设置誓约留场效果，并注册连锁被无效时将本卡从墓地取回的效果。
function c18446701.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁的ID，用于标记本次发动，以便后续连锁被无效时对应判断。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只魔法师族怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c18446701.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监听本连锁被无效的辅助效果e2注册到当前玩家tp的场上，使连锁被无效时能触发取回处理。
	Duel.RegisterEffect(e2,tp)
end
-- 当本卡发动的连锁被无效时，检查被无效连锁的ID是否为本卡的连锁ID；若是且本卡仍与该连锁关联，则取消此卡的送墓处理（CancelToGrave(false)），使此卡不被送去墓地。
function c18446701.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，用于与本次发动时记录的连锁ID比对。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 卡片过滤条件：对象必须为表侧表示且种族为魔法师族（用于选择己方场上魔法师族怪兽）。
function c18446701.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动时的取对象处理：确认已满足cost检查且存在合法对象；若有，则提示玩家选择装备对象，并在效果处理时将所选怪兽作为对象。
function c18446701.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18446701.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在至少1只表侧魔法师族怪兽可作为装备对象，以决定效果能否发动。
		and Duel.IsExistingTarget(c18446701.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向当前玩家发送选择装备对象的提示消息（HINTMSG_EQUIP，即请选择要装备的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让当前玩家从自己场上选择1只表侧魔法师族怪兽作为装备对象，并将其登记为本连锁的对象卡。
	Duel.SelectTarget(tp,c18446701.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记本次操作信息：效果分类为装备（CATEGORY_EQUIP），涉及的卡片为本卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：确认本卡仍在魔陷区且与效果关联；获取装备对象，若对象仍合法（表侧、自己场上、魔法师族），则装备本卡并赋予装备怪兽每回合最多2次不被战斗·效果破坏的抗破坏效果，同时设定装备限制；否则本卡送去墓地。
function c18446701.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的对象怪兽（装备目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_SPELLCASTER) then
		-- 将本卡作为装备卡装备给目标怪兽tc，装备控制者为当前玩家tp。
		Duel.Equip(tp,c,tc)
		-- 装备怪兽1回合最多2次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(2)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作装备卡使用给那只自己的魔法师族怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c18446701.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 定义本卡作为装备卡时的装备对象限制：允许装备给当前装备目标，或装备给当前玩家的魔法师族怪兽（防止装备对象不合法而自坏）。
function c18446701.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_SPELLCASTER)
end
