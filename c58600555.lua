--電子光虫－コアベージ
-- 效果：
-- 昆虫族·光属性5星怪兽×2只以上
-- 这张卡也能从自己场上的3·4阶的昆虫族超量怪兽把2个超量素材取除，在那只超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只守备表示怪兽为对象才能发动。那只怪兽回到持有者卡组。
-- ②：1回合1次，场上的怪兽的表示形式变更的场合才能发动。选自己墓地1只昆虫族怪兽在这张卡下面重叠作为超量素材。
function c58600555.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,c58600555.mfilter,5,2,c58600555.ovfilter,aux.Stringid(58600555,2),99,c58600555.xyzop)  --"是否在在超量怪兽上面重叠来超量召唤？"
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只守备表示怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58600555,0))  --"回到持有者卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c58600555.tdcost)
	e2:SetTarget(c58600555.tdtg)
	e2:SetOperation(c58600555.tdop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，场上的怪兽的表示形式变更的场合才能发动。选自己墓地1只昆虫族怪兽在这张卡下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58600555,1))  --"增加超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c58600555.condition)
	e3:SetTarget(c58600555.target)
	e3:SetOperation(c58600555.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己场上表侧表示的3或4阶昆虫族超量怪兽，用于重叠超量召唤
function c58600555.ovfilter(c)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsRank(3,4) and c:IsRace(RACE_INSECT)
end
-- 过滤函数：筛选符合正规超量召唤素材要求的昆虫族·光属性怪兽
function c58600555.mfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 超量召唤手续的操作函数：从作为素材的超量怪兽上取除2个超量素材
function c58600555.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	mc:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c58600555.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：筛选对方场上可以作为效果①对象的守备表示且能回到卡组的怪兽
function c58600555.tdfilter(c)
	return c:IsPosition(POS_DEFENSE) and c:IsAbleToDeck()
end
-- 效果①的发动准备：检查并选择对方场上1只守备表示怪兽作为对象，并设置操作信息
function c58600555.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c58600555.tdfilter(chkc) end
	-- 检查对方场上是否存在至少1只符合条件的守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c58600555.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只符合条件的对方场上的守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58600555.tdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽送回持有者卡组并洗牌
function c58600555.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数：筛选表示形式发生变更（攻防状态切换）的怪兽
function c58600555.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return ((np<3 and pp>3) or (pp<3 and np>3))
end
-- 效果②的发动条件：场上有怪兽的表示形式发生变更
function c58600555.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c58600555.cfilter,1,nil)
end
-- 过滤函数：筛选自己墓地中可以作为超量素材的昆虫族怪兽
function c58600555.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsCanOverlay()
end
-- 效果②的发动准备：检查自身是否为超量怪兽，且自己墓地是否存在可作为素材的昆虫族怪兽
function c58600555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在至少1只符合条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c58600555.matfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的效果处理：选择自己墓地1只昆虫族怪兽重叠作为这张卡的超量素材
function c58600555.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从自己墓地选择1只符合条件且不受王家长眠之谷影响的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c58600555.matfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽重叠作为这张卡的超量素材
		Duel.Overlay(c,g)
	end
end
