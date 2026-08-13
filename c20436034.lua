--磁力の指輪
-- 效果：
-- 自己场上的怪兽才可以装备。装备的怪兽攻击力·守备力下降500。对方只能攻击装备了这张卡的怪兽。
function c20436034.initial_effect(c)
	-- 自己场上的怪兽才可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c20436034.target)
	e1:SetOperation(c20436034.operation)
	c:RegisterEffect(e1)
	-- 装备的怪兽攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 装备的怪兽攻击力·守备力下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_ONLY_BE_ATTACKED)
	c:RegisterEffect(e4)
	-- 对方只能攻击装备了这张卡的怪兽。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(c20436034.eqlimit)
	c:RegisterEffect(e6)
end
-- 效果发动时的目标处理：确认对象为表侧表示怪兽；检查自己场上是否存在表侧表示怪兽；若可发动，提示玩家选择1只自己场上表侧表示怪兽作为装备对象，并登记装备处理的操作信息。
function c20436034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动合法性检查：确认自己场上有至少1只表侧表示怪兽可以作为效果对象（否则不能发动）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择装备对象的提示消息，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧表示怪兽，将其作为本效果的发动对象（取对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记连锁的操作信息：声明本效果处理时将进行装备（CATEGORY_EQUIP），处理对象为本卡，数量为1，供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得之前选择的对象；若这张装备卡仍与效果关联、对象仍与效果关联且为表侧表示并由自己控制，则执行装备。若条件不满足则不处理。
function c20436034.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁效果处理时记录的第一张对象卡（即发动时选择的装备对象怪兽）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张磁力指轮作为装备卡，装备给目标怪兽（由tp玩家控制）。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制判定：仅当目标怪兽的控制者与这张装备卡的控制者为同一人（即自己场上的怪兽）时，才允许装备。
function c20436034.eqlimit(e,c)
	return e:GetHandlerPlayer()==c:GetControler()
end
