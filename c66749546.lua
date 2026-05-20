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
-- 过滤场上表侧表示的水属性怪兽
function c66749546.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 装备效果的发动准备与对象选择判定
function c66749546.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66749546.filter(chkc) and chkc~=c end
	-- 判定自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():CheckUniqueOnField(tp)
		-- 判定自己场上是否存在除自身以外的水属性怪兽作为合法的装备对象
		and Duel.IsExistingTarget(c66749546.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只水属性怪兽作为装备对象
	Duel.SelectTarget(tp,c66749546.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 装备效果的处理，将自身作为装备卡装备给目标怪兽
function c66749546.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取作为装备对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔法与陷阱区域是否有空位、目标怪兽是否仍在自己场上表侧表示存在、以及自身是否能合法留在场上
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若无法装备，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 从自己的手卡·场上把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c66749546.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制这张卡只能装备给作为对象的那只怪兽
function c66749546.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 检查装备怪兽是否为「冰水」怪兽
function c66749546.dacon(e,ctp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget():IsSetCard(0x16c)
end
-- 过滤对方场上表侧表示、攻击力在装备怪兽守备力以下且能回到手卡的怪兽
function c66749546.spfilter(c,def)
	return c:IsFaceup() and c:IsAttackBelow(def) and c:IsAbleToHand()
end
-- 特殊召唤与弹回手卡效果的发动准备与对象选择判定
function c66749546.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsDefenseAbove(0)
		-- 判定自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定对方场上是否存在持有装备怪兽守备力以下攻击力的怪兽
		and Duel.IsExistingTarget(c66749546.spfilter,tp,0,LOCATION_MZONE,1,nil,ec:GetDefense()) end
	-- 提示玩家选择要返回手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只持有装备怪兽守备力以下攻击力的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66749546.spfilter,tp,0,LOCATION_MZONE,1,1,nil,ec:GetDefense())
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置将目标怪兽送回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 特殊召唤与弹回手卡效果的处理
function c66749546.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取作为弹回手卡对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 尝试将这张卡特殊召唤，若特殊召唤成功且目标怪兽仍适用效果，则继续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and tc:IsRelateToEffect(e) then
		-- 将作为对象的那只对方怪兽送回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
