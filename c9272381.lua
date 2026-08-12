--星輝士 セイクリッド・ダイヤ
-- 效果：
-- 光属性5星怪兽×3只以上
-- 这张卡也能在自己主要阶段2在「星辉士 星圣冬钻龙」以外的自己场上的「星骑士」超量怪兽上面重叠来超量召唤。
-- ①：只要持有超量素材的这张卡在怪兽区域存在，双方不能从卡组把卡送去墓地，从墓地回到手卡的卡不回到手卡而除外。
-- ②：对方把暗属性怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c9272381.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),5,3,c9272381.ovfilter,aux.Stringid(9272381,0),99)  --"是否在「星骑士」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，双方不能从卡组把卡送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetCondition(c9272381.effcon)
	c:RegisterEffect(e1)
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，双方不能从卡组把卡送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISCARD_DECK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c9272381.effcon)
	c:RegisterEffect(e2)
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，...从墓地回到手卡的卡不回到手卡而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_TO_HAND_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetCondition(c9272381.effcon)
	c:RegisterEffect(e3)
	-- ②：对方把暗属性怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9272381,1))  --"无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCondition(c9272381.condition)
	e4:SetCost(c9272381.cost)
	e4:SetTarget(c9272381.target)
	e4:SetOperation(c9272381.operation)
	c:RegisterEffect(e4)
end
-- 定义重叠超量召唤的素材过滤条件（主要阶段2自己场上「星辉士 星圣冬钻龙」以外的「星骑士」超量怪兽）
function c9272381.ovfilter(c)
	-- 检查目标怪兽是否为表侧表示、属于「星骑士」系列、是超量怪兽、卡名不是「星辉士 星圣冬钻龙」，且当前处于主要阶段2
	return c:IsFaceup() and c:IsSetCard(0x9c) and c:IsType(TYPE_XYZ) and not c:IsCode(9272381) and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义永续效果的适用条件：这张卡持有超量素材
function c9272381.effcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 定义效果②的发动条件：对方发动暗属性怪兽的效果，且该发动可以被无效
function c9272381.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中发动效果的卡片在连锁发生时的属性
	local attr=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTRIBUTE)
	-- 判断是否为对方发动的暗属性怪兽效果，且该发动可以被无效
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and attr&ATTRIBUTE_DARK>0 and Duel.IsChainNegatable(ev)
end
-- 定义效果②的发动代价：取除这张卡的1个超量素材
function c9272381.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果②的靶向/操作信息设置：确认发动无效与破坏的操作
function c9272381.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义效果②的具体效果处理：使发动无效并破坏
function c9272381.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
