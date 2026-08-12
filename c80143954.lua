--オルターガイスト・カモフラージュ
-- 效果：
-- ①：以自己场上1只「幻变骚灵」怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会被作为对方怪兽的攻击对象。（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击。）
-- ②：装备怪兽为对象发动的对方怪兽的效果无效化。
-- ③：自己场上的「幻变骚灵」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c80143954.initial_effect(c)
	-- ①：以自己场上1只「幻变骚灵」怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会被作为对方怪兽的攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c80143954.cost)
	e1:SetTarget(c80143954.target)
	e1:SetOperation(c80143954.activate)
	c:RegisterEffect(e1)
	-- ②：装备怪兽为对象发动的对方怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c80143954.negcon)
	e2:SetOperation(c80143954.negop)
	c:RegisterEffect(e2)
	-- ③：自己场上的「幻变骚灵」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c80143954.reptg)
	e3:SetValue(c80143954.repval)
	e3:SetOperation(c80143954.repop)
	c:RegisterEffect(e3)
end
-- 发动代价：在发动时将自身留在场上，并注册连锁被无效时送去墓地的辅助效果
function c80143954.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 以自己场上1只「幻变骚灵」怪兽为对象才能把这张卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c80143954.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册连锁无效时将卡片送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的处理：如果当前无效的连锁是本卡的发动，则将本卡送去墓地
function c80143954.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：自己场上表侧表示的「幻变骚灵」怪兽
function c80143954.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103)
end
-- 发动时的效果对象选择与合法性检测
function c80143954.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c80143954.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检测自己场上是否存在可以作为装备对象的表侧表示「幻变骚灵」怪兽
		and Duel.IsExistingTarget(c80143954.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「幻变骚灵」怪兽作为效果对象
	Duel.SelectTarget(tp,c80143954.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息为：装备1张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动后的效果处理：将自身作为装备卡装备给目标怪兽，并赋予不成为攻击对象的效果
function c80143954.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c80143954.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备怪兽不会被作为对方怪兽的攻击对象。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备在自己场上的「幻变骚灵」怪兽上
function c80143954.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x103)
end
-- 效果无效的条件：对方怪兽发动了以装备怪兽为对象的效果
function c80143954.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and g and g:IsContains(tc)
end
-- 效果无效的处理：使该怪兽效果无效
function c80143954.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 代替破坏的过滤条件：自己场上因战斗或效果被破坏的「幻变骚灵」卡
function c80143954.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsOnField()
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的检测与询问：检测墓地的这张卡是否可以除外，并询问玩家是否代替破坏
function c80143954.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c80143954.repfilter,1,nil,tp) end
	-- 询问玩家是否适用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的价值判定：确定被破坏的卡是否符合代替条件
function c80143954.repval(e,c)
	return c80143954.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的操作：将墓地的这张卡除外
function c80143954.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
