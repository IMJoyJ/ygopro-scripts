--氷水艇キングフィッシャー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：以自己场上1只水属性怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备。
-- ②：有这张卡装备的「冰水」怪兽可以用守备表示的状态作出攻击。那个场合，装备怪兽用守备力当作攻击力使用进行伤害计算。
-- ③：以持有装备怪兽的守备力以下的攻击力的对方场上1只怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到手卡。
function c66749546.initial_effect(c)
	-- ①：以自己场上1只水属性怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66749546,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c66749546.eqtg)
	e1:SetOperation(c66749546.eqop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的「冰水」怪兽可以用守备表示的状态作出攻击。那个场合，装备怪兽用守备力当作攻击力使用进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetCondition(c66749546.dacon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：以持有装备怪兽的守备力以下的攻击力的对方场上1只怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,66749546)
	e3:SetTarget(c66749546.sptg)
	e3:SetOperation(c66749546.spop)
	c:RegisterEffect(e3)
end
-- 装备对象过滤函数：必须是表侧表示的水属性怪兽。
function c66749546.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ①效果的目标函数：取对象确认时检查候选是否为自己场上表侧表示的水属性怪兽（这张卡本身除外），发动条件确认时检查自己魔法·陷阱区域有空位、这张卡能正常放置且场上存在可作为对象的水属性怪兽。
function c66749546.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66749546.filter(chkc) and chkc~=c end
	-- 发动条件检查之一：自己魔法·陷阱区域必须有空位才能放置这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 发动条件检查之二：自己场上必须存在可以作为对象的水属性怪兽（这张卡本身除外）。
		and Duel.IsExistingTarget(c66749546.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 向玩家发送「请选择要装备的卡」的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只水属性怪兽作为装备对象，并将其设为连锁对象。
	Duel.SelectTarget(tp,c66749546.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- ①效果的处理函数：确认这张卡仍与效果相关且（在场上的场合）不是里侧表示；取回对象怪兽后，若魔法·陷阱区域无空位、对象控制权变更、对象变为里侧表示、对象不再与效果相关或这张卡无法正常放置，则把这张卡送去墓地并中止；否则把这张卡当作装备卡装备给对象怪兽，并注册只影响自身的装备对象限制效果。
function c66749546.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取回当前连锁的对象卡（即要装备的目标怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查装备前置条件是否失效：魔法·陷阱区域没有空位、对象控制权转移给对方、对象变为里侧表示、对象不再与本效果相关，或这张卡无法满足场上唯一放置条件。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 条件失效时，把这张卡以效果送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 把这张卡当作装备卡使用装备给目标怪兽，装备失败则中止处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- ①：从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备（装备对象限定为那只怪兽）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c66749546.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备对象限制函数：这张卡只能装备给记录的那只怪兽。
function c66749546.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果适用条件：装备这张卡的怪兽是「冰水」怪兽。
function c66749546.dacon(e,ctp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget():IsSetCard(0x16c)
end
-- ③效果的对象过滤函数：对方场上表侧表示、攻击力在装备怪兽守备力以下且可以回到手卡的怪兽。
function c66749546.spfilter(c,def)
	return c:IsFaceup() and c:IsAttackBelow(def) and c:IsAbleToHand()
end
-- ③效果的目标函数：发动条件为这张卡有装备对象且装备怪兽守备力在0以上、自己主要怪兽区域有空位且这张卡可以特殊召唤、对方场上存在攻击力在装备怪兽守备力以下的可作为对象的怪兽。
function c66749546.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsDefenseAbove(0)
		-- 发动条件检查：自己主要怪兽区域必须有空位，且这张卡可以被特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 发动条件检查：对方场上必须存在攻击力在装备怪兽守备力以下的可以作为对象的怪兽。
		and Duel.IsExistingTarget(c66749546.spfilter,tp,0,LOCATION_MZONE,1,nil,ec:GetDefense()) end
	-- 向玩家发送「请选择要返回手牌的卡」的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只攻击力在装备怪兽守备力以下的怪兽作为对象，并将其设为连锁对象。
	local g=Duel.SelectTarget(tp,c66749546.spfilter,tp,0,LOCATION_MZONE,1,1,nil,ec:GetDefense())
	-- 设置操作信息：本次连锁将特殊召唤这张卡（1只）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：本次连锁将使作为对象的1只怪兽回到手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果的处理函数：确认这张卡仍与效果相关后取回对象怪兽；将这张卡以表侧表示特殊召唤，若特殊召唤成功且对象怪兽仍与效果相关，则把对象怪兽送回手卡。
function c66749546.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取回当前连锁的对象卡（即要回到手卡的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 把这张卡以表侧表示特殊召唤到自己场上，并确认特殊召唤成功且对象怪兽仍与本效果相关。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		-- 把作为对象的对方怪兽送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
