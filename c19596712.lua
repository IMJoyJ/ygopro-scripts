--アビスケイル－ケートス
-- 效果：
-- 名字带有「水精鳞」的怪兽才能装备。装备怪兽的攻击力上升800。只要这张卡在场上存在，对方场上发动的陷阱卡的效果无效。那之后，这张卡送去墓地。
function c19596712.initial_effect(c)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19596712.target)
	e1:SetOperation(c19596712.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 名字带有「水精鳞」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c19596712.eqlimit)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在，对方场上发动的陷阱卡的效果无效。那之后，这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c19596712.negcon)
	e4:SetOperation(c19596712.negop)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否为名字带有「水精鳞」的怪兽（0x74），作为该装备卡的装备限制条件。
function c19596712.eqlimit(e,c)
	return c:IsSetCard(0x74)
end
-- 筛选条件：怪兽为表侧表示且名字带有「水精鳞」（0x74）。
function c19596712.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74)
end
-- 发动时选择目标处理：选择场上1只表侧表示的水精鳞怪兽作为装备对象，并设置装备分类的操作信息。
function c19596712.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19596712.filter(chkc) end
	-- 发动时确认场上是否存在至少1只符合条件的表侧表示水精鳞怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c19596712.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择装备对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方的怪兽区域选择1只符合条件的表侧表示水精鳞怪兽作为装备对象。
	Duel.SelectTarget(tp,c19596712.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备处理，对象为这张卡本身，以便后续效果处理时进行装备动作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备操作：若这张卡和选择的对象仍存在且对象仍表侧表示，则将这张卡装备给该对象。
function c19596712.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡（即装备目标）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 无效效果的发动条件：对方玩家发动陷阱卡且连锁发生位置在魔陷区，且该连锁效果可以被无效。
function c19596712.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：该连锁由对方玩家发动，且连锁发生的位置在对方的魔陷区。
	return rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_SZONE
		-- 且该连锁效果为陷阱卡的效果，并且该连锁效果是可以被无效的效果。
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 效果处理：成功无效对方发动的陷阱卡效果后，将这张装备卡送去墓地。
function c19596712.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试将对方发动的那次连锁效果无效；若无效成功则执行后续处理。
	if Duel.NegateEffect(ev,true) then
		-- 将这张卡以效果原因送去墓地（对应“那之后，这张卡送去墓地”）。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
