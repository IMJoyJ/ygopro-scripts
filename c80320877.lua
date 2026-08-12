--終刻決壊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「终刻」超量怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●对方不能用抽卡以外的方法从卡组把卡加入手卡。
-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。从卡组把1只「终刻」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 注册卡片效果：①发动并作为装备卡装备的效果，②被效果破坏时从卡组将「终刻」怪兽装备给场上怪兽的效果。
function s.initial_effect(c)
	-- ①：以自己场上1只「终刻」超量怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。从卡组把1只「终刻」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组装备"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 魔法卡发动时的Cost处理，用于处理永续魔法/装备魔法在发动无效时送去墓地的规则性处理。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- ①：以自己场上1只「终刻」超量怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只「终刻」超量怪兽为对象才能把这张卡发动。这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(s.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理发动无效时将卡片送去墓地的全局辅助效果。
	Duel.RegisterEffect(e2,tp)
end
-- 发动无效时的辅助操作：如果本卡的发动被无效，则取消其送去墓地的确定状态。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的连锁ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤自己场上表侧表示的「终刻」超量怪兽。
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d2) and c:IsType(TYPE_XYZ)
end
-- ①效果的发动准备与合法性检测（检查场上是否存在可选的「终刻」超量怪兽）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件的「终刻」超量怪兽。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「终刻」超量怪兽作为效果的对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只能装备给作为对象的「终刻」超量怪兽。
function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c and c:IsSetCard(0x1d2)
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_XYZ)
end
-- ①效果的处理：将自身装备给目标怪兽，并赋予“对方不能从卡组将卡加入手卡”的装备效果，同时设置装备限制。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToChain() or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取作为装备对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- ●对方不能用抽卡以外的方法从卡组把卡加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TO_HAND)
		e1:SetRange(LOCATION_SZONE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		-- 限制加入手卡的卡的来源为卡组。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(s.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- ②效果的发动条件：这张卡被效果破坏。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 过滤场上表侧表示的怪兽。
function s.tgfilter(c)
	return c:IsFaceup()
end
-- 过滤卡组中可以作为装备卡装备的「终刻」怪兽。
function s.eqfilter2(c,tp)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- ②效果的发动准备与合法性检测（检查魔法与陷阱区域是否有空位、场上是否有表侧表示怪兽、卡组中是否有可装备的「终刻」怪兽）。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	-- 检查自己的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在至少1只表侧表示怪兽。
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查卡组中是否存在至少1只可装备的「终刻」怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含从卡组装备卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1只「终刻」怪兽，当作装备魔法卡装备给作为对象的目标怪兽，并设置装备限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为装备对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍在场上表侧表示存在，且自己的魔法与陷阱区域是否有空位。
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组选择1只满足条件的「终刻」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_DECK,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			-- 将选择的「终刻」怪兽作为装备卡装备给目标怪兽，若装备失败则结束处理。
			if not Duel.Equip(tp,ec,tc) then return end
			-- 从卡组把1只「终刻」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制：只能装备给作为对象的怪兽。
function s.eqlimit2(e,c)
	return c==e:GetLabelObject()
end
