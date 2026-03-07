--ZW－天馬双翼剣
-- 效果：
-- ①：「异热同心武器-天马双翼剑」在自己场上只能有1张表侧表示存在。
-- ②：自己基本分比对方少2000以上的场合，这张卡可以从手卡特殊召唤。
-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
-- ④：这张卡装备中的场合，1回合1次，由对方在场上发动的怪兽的效果的处理时，可以把那个效果无效。
function c32164201.initial_effect(c)
	c:SetUniqueOnField(1,0,32164201)
	-- ②：自己基本分比对方少2000以上的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32164201.spcon)
	c:RegisterEffect(e1)
	-- ③：以自己场上1只「希望皇 霍普」怪兽为对象才能发动。自己场上的这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32164201,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c32164201.eqcon)
	e2:SetTarget(c32164201.eqtg)
	e2:SetOperation(c32164201.eqop)
	c:RegisterEffect(e2)
	-- ④：这张卡装备中的场合，1回合1次，由对方在场上发动的怪兽的效果的处理时，可以把那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c32164201.negcon)
	e3:SetOperation(c32164201.negop)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件：自己的基本分比对方少2000以上且场上存在可用怪兽区域。
function c32164201.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己的基本分是否比对方少2000以上。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
		-- 判断自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 判断装备效果是否满足发动条件：装备卡在场上的唯一性检查。
function c32164201.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 筛选满足条件的「希望皇 霍普」怪兽。
function c32164201.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 设置装备效果的目标选择条件：选择自己场上的「希望皇 霍普」怪兽。
function c32164201.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c32164201.filter(chkc) end
	-- 判断装备效果是否可以发动：场上是否有可用的魔陷区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备目标选择条件：场上是否存在符合条件的「希望皇 霍普」怪兽。
		and Duel.IsExistingTarget(c32164201.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择符合条件的「希望皇 霍普」怪兽作为装备目标。
	Duel.SelectTarget(tp,c32164201.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行装备操作：将装备卡装备给目标怪兽。
function c32164201.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取装备效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断装备是否可以成功执行：场上是否有可用魔陷区域、目标怪兽是否为表侧表示、是否满足唯一性条件。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若装备失败则将装备卡送入墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c32164201.zw_equip_monster(c,tp,tc)
end
-- 执行装备卡的装备处理：设置装备限制和攻击力加成效果。
function c32164201.zw_equip_monster(c,tp,tc)
	-- 尝试将装备卡装备给目标怪兽。
	if not Duel.Equip(tp,c,tc) then return end
	-- 设置装备卡的装备限制效果：只能装备给特定怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c32164201.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡的攻击力加成效果：装备后攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 判断装备卡是否只能装备给特定怪兽。
function c32164201.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断是否满足无效效果的条件：装备卡已装备、对方发动效果、效果来自怪兽区域、效果可被无效、本回合未使用过该效果。
function c32164201.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断装备卡是否已装备、对方是否发动效果、效果来自怪兽区域。
	return c:GetEquipTarget() and rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		-- 判断发动的效果是否为怪兽效果、效果是否可被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and c:GetFlagEffect(32164201)==0
end
-- 执行无效效果的操作：询问是否使用装备卡效果、无效对方效果、记录使用标志。
function c32164201.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否使用装备卡效果。
	if Duel.SelectYesNo(tp,aux.Stringid(32164201,1)) then  --"是否使用「异热同心武器-天马双翼剑」的效果？"
		-- 提示对方发动了装备卡。
		Duel.Hint(HINT_CARD,0,32164201)
		-- 使对方的效果无效。
		Duel.NegateEffect(ev)
		e:GetHandler():RegisterFlagEffect(32164201,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
