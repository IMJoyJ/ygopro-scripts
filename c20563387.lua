--CNo.80 葬装覇王レクイエム・イン・バーサーク
-- 效果：
-- 5星怪兽×3
-- ①：以自己场上1只超量怪兽为对象才能发动。自己场上的这张卡当作攻击力上升2000的装备卡使用给那只自己怪兽装备。
-- ②：装备怪兽被破坏的场合，作为代替把这张卡破坏。
-- ③：这张卡有「No.80 狂装霸王 狂想战曲王」在作为超量素材的场合，得到以下效果。
-- ●把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡除外。
function c20563387.initial_effect(c)
	-- 为这张卡设定XYZ召唤手续：以3只5星怪兽为素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：以自己场上1只超量怪兽为对象才能发动。自己场上的这张卡当作攻击力上升2000的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20563387,0))  --"当作装备卡给自己场上的超量怪兽装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c20563387.eqtg)
	e1:SetOperation(c20563387.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡有「No.80 狂装霸王 狂想战曲王」在作为超量素材的场合，得到以下效果。●把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20563387,1))  --"选择场上1张卡从游戏中除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c20563387.rmcon)
	e2:SetCost(c20563387.rmcost)
	e2:SetTarget(c20563387.rmtg)
	e2:SetOperation(c20563387.rmop)
	c:RegisterEffect(e2)
end
-- 将该卡登记为编号No.80系列，用于相关规则判定。
aux.xyz_number[20563387]=80
-- 定义装备对象筛选函数：筛选自己场上表侧表示的超量怪兽。
function c20563387.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ①效果的发动条件与取对象：检查魔陷区有空格且自己场上有可装备的表侧表示超量怪兽，并选定1只作为装备对象（不能选这张卡自身）。
function c20563387.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20563387.filter(chkc) and chkc~=e:GetHandler() end
	-- 效果发动合法性检查：自己魔陷区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己场上存在可供装备的表侧表示超量怪兽（本卡以外）作为取对象目标。
		and Duel.IsExistingTarget(c20563387.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只自己场上的表侧表示超量怪兽作为装备对象，并登记为效果处理时的对象。
	Duel.SelectTarget(tp,c20563387.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ①效果处理：若本卡仍与效果关联且表侧表示，则将本卡作为装备卡装备给目标怪兽；随后赋予装备限制、攻击力上升2000和代替破坏效果；若条件不满足则将本卡送去墓地。
function c20563387.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取装备对象（发动时选择的超量怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 处理时判定：若魔陷区无空格、目标已不在自己场上/为里侧/与效果失去关联，则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不成立时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备到目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c20563387.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(2000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- ②：装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 装备限制判定：仅允许装备在发动时选择的目标怪兽上。
function c20563387.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ③的发动条件：这张卡的超量素材中存在「No.80 狂装霸王 狂想战曲王」时才能发动除外效果。
function c20563387.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,93568288)
end
-- 除外效果的发动代价：取除这张卡的1个超量素材。
function c20563387.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③·除外效果的取对象与操作信息设定：检查场上存在可除外的卡，选择场上1张卡为对象，并登记除外操作信息。
function c20563387.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 发动合法性检查：场上存在可以被除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张卡作为除外对象，并登记为效果处理时的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将当前连锁的操作信息设定为除外1张卡，供相关卡片（如星尘龙）进行效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果处理：若对象仍与效果关联，则将其表侧表示除外。
function c20563387.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外对象（发动时选择的场上1张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示从游戏中除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
