--騎竜ドラコバック
-- 效果：
-- 自己场上的怪兽才能装备。这个卡名的②③的效果1回合各能使用1次。
-- ①：「骑龙 驮龙」在自己场上只能有1张表侧表示存在。
-- ②：这张卡给效果怪兽以外的怪兽装备中的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
function c38745520.initial_effect(c)
	-- 将「勇者衍生物」(卡号3285552)登记为本卡效果文中记载的卡名，用于关联检索/判定相关卡片。
	aux.AddCodeList(c,3285552)
	c:SetUniqueOnField(1,0,38745520)
	-- 自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c38745520.target)
	e1:SetOperation(c38745520.activate)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c38745520.eqlimit)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。②：这张卡给效果怪兽以外的怪兽装备中的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,38745520)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c38745520.thcon)
	e3:SetTarget(c38745520.thtg)
	e3:SetOperation(c38745520.thop)
	c:RegisterEffect(e3)
	-- 这个卡名的②③的效果1回合各能使用1次。③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,38745521)
	e4:SetTarget(c38745520.eqtg)
	e4:SetOperation(c38745520.eqop)
	c:RegisterEffect(e4)
end
-- 装备魔法发动时的取对象处理：选择自己场上1只表侧表示的怪兽作为这张卡的装备对象，并设置装备操作信息。
function c38745520.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 效果发动合法性判定：自己场上是否存在至少1只表侧表示怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 让玩家选择自己场上1只表侧表示怪兽作为装备对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本连锁将进行‘装备’处理，对象为选择的那1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备魔法发动成功的处理：若这张卡和目标怪兽都仍与效果关联且目标表侧表示，则将这张卡装备给目标怪兽。
function c38745520.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备魔法卡装备给玩家tp场上的目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制判定：这张卡只能装备给自己场上的怪兽（装备对象必须是本卡控制者控制的怪兽）。
function c38745520.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- ②效果的发动条件：这张卡当前装备给怪兽，且该装备对象不是效果怪兽。
function c38745520.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
-- ②效果的取对象处理：选择对方场上1张能够返回手牌的卡作为对象，并设置返回手牌的操作信息。
function c38745520.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 效果发动合法性判定：对方场上是否存在至少1张能够返回手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示‘请选择要返回手牌的卡’的提示信息，用于选择卡片的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张能返回手牌的卡作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本连锁将进行‘返回手牌’处理，对象为选择的那1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：获取对象卡，若仍与效果关联，则将该卡返回持有者手卡。
function c38745520.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对方场上的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡返回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断是否为表侧表示的「勇者衍生物」（卡号3285552），用于③效果选择装备对象的过滤器。
function c38745520.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- ③效果的取对象处理：选择自己场上1只表侧表示的「勇者衍生物」作为对象，并检查魔陷区空位和本卡唯一性满足后设置装备/离开墓地的操作信息。
function c38745520.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c38745520.cfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	local c=e:GetHandler()
	-- 效果发动合法性判定：自己场上是否存在至少1只表侧表示的「勇者衍生物」可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c38745520.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并检查自己魔陷区是否有空位容纳这张装备卡，以及这张卡是否满足‘骑龙 驮龙’在自己场上只能有1张表侧表示存在的唯一性限制。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) end
	-- 显示‘请选择要装备的卡’的提示信息，用于选择装备对象的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只表侧表示的「勇者衍生物」作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c38745520.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本连锁将进行‘装备’处理，装备卡为这张卡本身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置操作信息：本连锁涉及这张卡从墓地离开（重新装备回场上），供相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ③效果处理：确认魔陷区有空位后，检查这张卡和目标衍生物仍与效果关联、衍生物表侧表示、本卡满足唯一性，则将这张卡从墓地装备给目标衍生物。
function c38745520.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：若自己魔陷区没有可用空位，则无法将这张卡装备，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取③效果发动时选择的「勇者衍生物」对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		-- 将这张卡从墓地作为装备魔法卡装备给玩家tp场上的目标「勇者衍生物」。
		Duel.Equip(tp,c,tc)
	end
end
