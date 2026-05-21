--No.80 狂装覇王ラプソディ・イン・バーサーク
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合可以使用最多2次。
-- ①：把这张卡1个超量素材取除，以对方墓地1张卡为对象才能发动。那张卡除外。
-- ②：以自己场上1只超量怪兽为对象才能发动。自己场上的这张卡当作攻击力上升1200的装备卡使用给那只自己怪兽装备。
function c93568288.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 以自己场上1只超量怪兽为对象才能发动。自己场上的这张卡当作攻击力上升1200的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93568288,0))  --"当作装备卡给自己场上的超量怪兽装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c93568288.eqtg)
	e1:SetOperation(c93568288.eqop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合可以使用最多2次。①：把这张卡1个超量素材取除，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93568288,1))  --"选择对方墓地1张卡从游戏中除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(2,93568288)
	e2:SetCost(c93568288.rmcost)
	e2:SetTarget(c93568288.rmtg)
	e2:SetOperation(c93568288.rmop)
	c:RegisterEffect(e2)
end
-- 设置该卡为“No.80”怪兽
aux.xyz_number[93568288]=80
-- 过滤条件：场上表侧表示的超量怪兽
function c93568288.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 装备效果（效果②）的靶向与发动条件判定
function c93568288.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c93568288.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件判定：检查自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件判定：检查自己场上是否存在除自身以外的表侧表示超量怪兽
		and Duel.IsExistingTarget(c93568288.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只除自身以外的表侧表示超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93568288.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息：装备分类，数量为1
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备效果（效果②）的效果处理
function c93568288.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then
		-- 若对象怪兽已不在场或变为里侧表示，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给对象怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 攻击力上升1200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 当作装备卡使用给那只自己怪兽装备
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c93568288.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetLabelObject(tc)
	c:RegisterEffect(e2)
end
-- 装备限制：只能装备给作为对象的那只怪兽
function c93568288.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 除外效果（效果①）的代价：把这张卡1个超量素材取除
function c93568288.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 除外效果（效果①）的靶向与发动条件判定
function c93568288.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动条件判定：检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：除外分类，数量为1，目标在对方墓地
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 除外效果（效果①）的效果处理
function c93568288.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
