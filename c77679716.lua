--超重武者装留ブレイク・アーマー
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。自己的手卡·场上的这只怪兽当作守备力下降1000的装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗破坏。
-- ②：自己主要阶段，从自己墓地把包含这张卡的「超重武者装留 破坏铠」全部除外，以守备力比原本守备力低的1只「超重武者」怪兽为对象才能发动。给与对方那只怪兽的守备力和那个原本守备力的相差数值的伤害。
function c77679716.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。自己的手卡·场上的这只怪兽当作守备力下降1000的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77679716,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c77679716.eqtg)
	e1:SetOperation(c77679716.eqop)
	c:RegisterEffect(e1)
	-- 装备怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段，从自己墓地把包含这张卡的「超重武者装留 破坏铠」全部除外，以守备力比原本守备力低的1只「超重武者」怪兽为对象才能发动。给与对方那只怪兽的守备力和那个原本守备力的相差数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77679716,1))  --"效果伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c77679716.damcost)
	e3:SetTarget(c77679716.damtg)
	e3:SetOperation(c77679716.damop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的「超重武者」怪兽
function c77679716.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果①的发动准备：检查魔陷区空位并选择自己场上1只「超重武者」怪兽作为对象
function c77679716.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c77679716.filter(chkc) end
	-- 在发动效果时，检查自己魔陷区是否有空余格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并检查自己场上是否存在除自身以外的表侧表示「超重武者」怪兽
		and Duel.IsExistingTarget(c77679716.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「超重武者」怪兽作为效果对象
	Duel.SelectTarget(tp,c77679716.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果①的处理：将自身作为装备卡装备给目标怪兽，并适用守备力下降1000的效果
function c77679716.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取作为装备对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位，以及目标怪兽是否仍由自己控制、是否表侧表示、是否仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若无法装备，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 当作...装备卡使用给那只自己怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c77679716.eqlimit)
	c:RegisterEffect(e1)
	-- 守备力下降1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(-1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 限制这张卡只能装备给「超重武者」怪兽
function c77679716.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 过滤墓地中可以作为Cost除外的「超重武者装留 破坏铠」
function c77679716.cfilter(c)
	return c:IsCode(77679716) and c:IsAbleToRemoveAsCost()
end
-- 效果②的Cost处理：将自己墓地中所有的「超重武者装留 破坏铠」全部除外
function c77679716.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 获取自己墓地中所有的「超重武者装留 破坏铠」
	local g=Duel.GetMatchingGroup(c77679716.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将这些卡全部表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤场上表侧表示、且当前守备力低于原本守备力的「超重武者」怪兽
function c77679716.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a) and c:GetDefense()<c:GetBaseDefense()
end
-- 效果②的发动准备：选择1只守备力比原本守备力低的「超重武者」怪兽作为对象，并声明伤害效果
function c77679716.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c77679716.damfilter(chkc) end
	-- 在发动效果时，检查场上是否存在守备力低于原本守备力的「超重武者」怪兽
	if chk==0 then return Duel.IsExistingTarget(c77679716.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只守备力低于原本守备力的「超重武者」怪兽作为效果对象
	Duel.SelectTarget(tp,c77679716.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果②的处理：给与对方目标怪兽当前守备力与原本守备力差值的伤害
function c77679716.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为伤害计算基准的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local val=math.abs(tc:GetDefense()-tc:GetBaseDefense())
		-- 给与对方玩家相应的效果伤害
		Duel.Damage(1-tp,val,REASON_EFFECT)
	end
end
