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
-- 特殊召唤规则的条件判定：若c为nil则视为规则召唤本身可直接使用；否则需满足自己LP比对方少2000以上且主怪兽区有空位。
function c29353756.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己基本分是否比对方少2000以上，即②的LP差距条件成立。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
		-- 同时要求自己场上有可用的主要怪兽区域，才能从手卡特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 作为起动效果的发动条件：确认此卡在自己场上仍满足同名卡只能有1张表侧表示存在的唯一性限制。
function c29353756.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 装备对象筛选条件：表侧表示且属于「希望皇」系列的怪兽。
function c29353756.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 目标判定：若指定对象则验证其位于自己主怪兽区且满足筛选；若为发动确认，则需魔陷区有空位且场上存在可装备的「希望皇 霍普」怪兽。
function c29353756.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29353756.filter(chkc) end
	-- 发动时检查自己魔陷区是否还有空位，以容纳这张装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时检查自己场上是否存在满足条件的「希望皇 霍普」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c29353756.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只满足条件的「希望皇 霍普」怪兽，并将其登记为该效果的对象。
	Duel.SelectTarget(tp,c29353756.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：确认此卡仍与效果关联且非里侧，再检查装备条件，若满足则将自身装备给目标怪兽，否则送去墓地。
function c29353756.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否仍成立：魔陷区有空位、对象仍在己方场上且表侧、对象与效果关联、此卡仍满足唯一性；任一不满足则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 因无法装备而将此卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c29353756.zw_equip_monster(c,tp,tc)
end
-- 将这张卡装备给目标「希望皇 霍普」怪兽，并为其追加攻击力上升2000的装备效果以及装备对象限制。
function c29353756.zw_equip_monster(c,tp,tc)
	-- 尝试执行装备，若装备失败则直接结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 对应“给那只自己的「希望皇 霍普」怪兽装备”：设置此装备卡只能装备给被选择的那只对象怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c29353756.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 对应“攻击力上升2000”：作为装备卡时，为装备怪兽提供2000攻击力加成。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(2000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定：只有当初选择的那只「希望皇 霍普」怪兽才能装备此卡。
function c29353756.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ④的发动条件：此卡装备中、对方发动陷阱卡、且该陷阱卡在对方场上发动。
function c29353756.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认此卡装备中、连锁来源为对方、且对方发动的卡位于魔陷区，即满足④的触发条件。
	return e:GetHandler():GetEquipTarget() and rp==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_SZONE
		and re:IsActiveType(TYPE_TRAP)
end
-- 效果处理：无效对方发动的陷阱卡的效果。
function c29353756.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示此卡，宣告无效陷阱卡效果。
	Duel.Hint(HINT_CARD,0,29353756)
	-- 使对方场上发动的陷阱卡所在连锁的效果无效。
	Duel.NegateEffect(ev)
end
