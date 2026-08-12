--CNo.80 葬装覇王レクイエム・イン・バーサーク
-- 效果：
-- 5星怪兽×3
-- ①：以自己场上1只超量怪兽为对象才能发动。自己场上的这张卡当作攻击力上升2000的装备卡使用给那只自己怪兽装备。
-- ②：装备怪兽被破坏的场合，作为代替把这张卡破坏。
-- ③：这张卡有「No.80 狂装霸王 狂想战曲王」在作为超量素材的场合，得到以下效果。
-- ●把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡除外。
function c20563387.initial_effect(c)
	-- 为卡片添加等级为5、需要3只怪兽的XYZ召唤手续
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
-- 设置该卡的XYZ编号为80
aux.xyz_number[20563387]=80
-- 定义用于筛选场上表侧表示的超量怪兽的函数
function c20563387.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置装备效果的目标选择函数，检查是否能选择自己场上的超量怪兽作为对象
function c20563387.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20563387.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否有足够的魔法陷阱区域来装备此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在满足条件的超量怪兽作为装备对象
		and Duel.IsExistingTarget(c20563387.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的超量怪兽作为装备对象
	Duel.SelectTarget(tp,c20563387.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 执行装备效果的操作，将此卡装备给目标怪兽并设置相关效果
function c20563387.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取当前连锁中选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括是否有足够的魔法陷阱区域、目标怪兽是否属于自己或表侧表示
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若装备条件不满足，则将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作，将此卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 设置装备对象限制效果，确保此卡只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c20563387.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡效果，使装备怪兽获得2000攻击力
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(2000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 设置装备卡的代替破坏效果，当装备怪兽被破坏时此卡代替破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetValue(1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 定义装备对象限制函数，确保此卡只能装备给特定怪兽
function c20563387.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断此卡是否有「No.80 狂装霸王 狂想战曲王」作为超量素材
function c20563387.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,93568288)
end
-- 设置除外效果的费用，消耗1个超量素材
function c20563387.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置除外效果的目标选择函数，检查是否能选择场上的卡作为除外对象
function c20563387.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录本次效果将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外效果的操作，将目标卡从游戏中除外
function c20563387.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的除外对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
