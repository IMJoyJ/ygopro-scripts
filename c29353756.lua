--ZW－荒鷲激神爪
-- 效果：
-- ①：「异热同心武器-荒鹫激神爪」在自己场上只能有1张表侧表示存在。
-- ②：自己基本分比对方少2000以上的场合，这张卡可以从手卡特殊召唤。
-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升2000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
-- ④：这张卡装备中的场合，1回合1次，对方场上发动的陷阱卡的效果无效。
function c29353756.initial_effect(c)
	c:SetUniqueOnField(1,0,29353756)
	-- ②：自己基本分比对方少2000以上的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c29353756.spcon)
	c:RegisterEffect(e1)
	-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升2000的装备卡使用给那只自己的「希望皇 霍普」怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29353756,0))  --"变成装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c29353756.eqcon)
	e2:SetTarget(c29353756.eqtg)
	e2:SetOperation(c29353756.eqop)
	c:RegisterEffect(e2)
	-- ④：这张卡装备中的场合，1回合1次，对方场上发动的陷阱卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c29353756.negcon)
	e3:SetOperation(c29353756.negop)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件，即自己的LP比对方少2000以上且场上存在可用怪兽区域。
function c29353756.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己的LP是否比对方少2000以上。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
		-- 判断自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 判断装备效果是否可以发动，即确认此卡在场上的唯一性。
function c29353756.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 定义筛选「希望皇 霍普」怪兽的条件，即该怪兽必须表侧表示且属于「希望皇 霍普」卡组。
function c29353756.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 设置装备效果的目标选择逻辑，即选择自己场上的「希望皇 霍普」怪兽作为装备对象。
function c29353756.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29353756.filter(chkc) end
	-- 判断装备效果是否可以发动，即自己场上是否有可用的魔陷区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否存在符合条件的「希望皇 霍普」怪兽作为装备对象。
		and Duel.IsExistingTarget(c29353756.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择符合条件的「希望皇 霍普」怪兽作为装备对象。
	Duel.SelectTarget(tp,c29353756.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行装备操作，若条件不满足则将装备卡送入墓地。
function c29353756.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取当前连锁中被选择的装备对象。
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括魔陷区域是否足够、目标怪兽是否合法等。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若装备条件不满足，则将装备卡送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c29353756.zw_equip_monster(c,tp,tc)
end
-- 执行装备卡与目标怪兽的装备过程，并设置装备限制和攻击力加成效果。
function c29353756.zw_equip_monster(c,tp,tc)
	-- 尝试将装备卡装备给目标怪兽，若失败则返回。
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备卡的装备对象限制，确保只能装备给特定怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c29353756.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡的攻击力加成效果，使装备怪兽攻击力上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(2000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 定义装备对象限制的具体条件，即只能装备给被标记的怪兽。
function c29353756.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断是否满足陷阱卡无效的条件，即装备卡已装备且对方发动陷阱卡。
function c29353756.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断装备卡是否已装备且对方发动陷阱卡。
	return e:GetHandler():GetEquipTarget() and rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_SZONE
		and re:IsActiveType(TYPE_TRAP)
end
-- 执行陷阱卡无效的操作，并提示发动了该卡。
function c29353756.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了该卡。
	Duel.Hint(HINT_CARD,0,29353756)
	-- 使对方发动的陷阱卡效果无效。
	Duel.NegateEffect(ev)
end
