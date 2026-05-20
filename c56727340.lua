--超重武者装留ガイア・ブースター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备卡使用给那只自己怪兽装备。装备怪兽当作调整使用。
-- ②：自己墓地没有魔法·陷阱卡存在，这张卡的效果让这张卡装备中的场合才能发动。这张卡特殊召唤。
function c56727340.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作装备卡使用给那只自己怪兽装备。装备怪兽当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56727340,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c56727340.eqtg)
	e1:SetOperation(c56727340.eqop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「超重武者」怪兽
function c56727340.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 装备效果的发动准备与合法性检测
function c56727340.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and c56727340.filter(chkc) end
	-- 检查自己场上的魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在除自身以外的「超重武者」怪兽作为合法的效果对象
		and Duel.IsExistingTarget(c56727340.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「超重武者」怪兽作为效果对象
	Duel.SelectTarget(tp,c56727340.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 装备效果的执行，将自身作为装备卡装备给目标怪兽，并赋予其调整状态和特殊召唤效果
function c56727340.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取作为装备对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、目标怪兽是否仍表侧表示存在于自己场上且仍为该效果的对象
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 从自己的手卡·场上把这张卡当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c56727340.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_TUNER)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己墓地没有魔法·陷阱卡存在，这张卡的效果让这张卡装备中的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,56727340)
	e3:SetCondition(c56727340.spcon)
	e3:SetTarget(c56727340.sptg)
	e3:SetOperation(c56727340.spop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 限定这张卡只能装备给选定的目标怪兽
function c56727340.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤效果的发动条件：这张卡处于装备状态，且自己墓地没有魔法·陷阱卡存在
function c56727340.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查这张卡是否装备在怪兽上，且自己墓地没有魔法·陷阱卡存在
	return ec and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤效果的发动准备与合法性检测
function c56727340.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行
function c56727340.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
