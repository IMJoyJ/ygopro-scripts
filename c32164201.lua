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
-- ②特殊召唤规则的发动条件判定：此卡作为手卡中的规则特殊召唤卡时，若自己LP比对方少2000以上且主要怪兽区有空位，则允许进行特殊召唤（c为nil时表示召唤手续本身合法）。
function c32164201.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己当前LP是否满足小于等于对方LP-2000，即自己基本分比对方少2000以上。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
		-- 确认自己主要怪兽区存在至少1个可用的怪兽区域，确保特殊召唤有足够的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- ③效果发动条件：通过CheckUniqueOnField确认场上不存在其他表侧表示的同名「异热同心武器-天马双翼剑」，即满足『自己场上只能有1张表侧表示存在』的限制。
function c32164201.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 定义可作为装备对象的怪兽筛选条件：表侧表示且属于字段「希望皇」（SetCard 0x107f）。
function c32164201.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- ③效果的发动时点：若为对象合法性确认则验证对象位于自己主要怪兽区且满足filter；若为发动合法性检查，则要求魔陷区有空位且存在满足条件的可选择的「希望皇」怪兽。
function c32164201.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c32164201.filter(chkc) end
	-- 发动合法性检查：要求自己魔陷区有至少1个空位，以便把这张卡放置到魔陷区作为装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 进一步要求自己场上存在至少1只表侧表示且属于「希望皇」字段的怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c32164201.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 在选择目标前向操作玩家显示『请选择要装备的卡』的提示，使选择框语义明确。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 令玩家从自己场上选择1只满足filter的「希望皇」怪兽，并将该卡登记为本次连锁的对象（取对象）。
	Duel.SelectTarget(tp,c32164201.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ③效果处理：先检查这张卡与效果的关联及自身表示状态；然后取得对象怪兽；若魔陷区空位不足、对象不合法或这张卡不再满足同名限制，则把这张卡送去墓地；否则执行装备处理。
function c32164201.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取该效果发动时选择的1只对象怪兽（装备目标）。
	local tc=Duel.GetFirstTarget()
	-- 装备前最终条件检查：我魔陷区必须有空位、对象怪兽必须表侧且仍与效果关联、这张卡必须仍满足同名卡只能有1张的限制，任一条件不满足则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 因为条件不满足导致无法装备，把这张卡以效果原因从场上送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c32164201.zw_equip_monster(c,tp,tc)
end
-- 实际装备处理：调用Duel.Equip把这张卡装备给目标怪兽，并为其注册装备限制与攻击力上升1000的装备效果；若装备失败则直接中止。
function c32164201.zw_equip_monster(c,tp,tc)
	-- 尝试进行装备操作，若装备失败则返回，不进行后续效果设置。
	if not Duel.Equip(tp,c,tc) then return end
	-- ③：自己场上的这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c32164201.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- ③：自己场上的这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定：仅当被装备的怪兽是这张卡装备效果发动时选择并记录的目标怪兽时返回true，从而把装备对象锁定为那只「希望皇」怪兽。
function c32164201.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ④效果触发条件：这张卡处于装备状态、对方在场上发动了怪兽效果且该连锁正在处理中、效果可被无效、且本回合尚未使用过此无效效果（通过flag实现1回合1次限制）。
function c32164201.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该连锁是否满足：这张卡有装备目标、连锁由对方玩家引发、连锁发生位置在怪兽区域。
	return c:GetEquipTarget() and rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		-- 判断该连锁效果是否为怪兽效果，并且当前效果可以被无效（未被其他效果保护）。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and c:GetFlagEffect(32164201)==0
end
-- ④效果处理：询问玩家是否发动无效效果；若同意，则向双方展示此卡，无效对方那一条连锁效果，并给自己设置本回合已使用的flag（回合结束重置）。
function c32164201.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择框，让玩家决定是否适用这张卡的效果来无效对方发动的怪兽效果。
	if Duel.SelectYesNo(tp,aux.Stringid(32164201,1)) then  --"是否适用「异热同心武器-天马双翼剑」的效果来无效？"
		-- 向双方玩家展示这张卡，以显示无效效果的发动动画。
		Duel.Hint(HINT_CARD,0,32164201)
		-- 使指定连锁（对方在场上发动的怪兽效果）无效。
		Duel.NegateEffect(ev)
		e:GetHandler():RegisterFlagEffect(32164201,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
