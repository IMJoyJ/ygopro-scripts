--結晶の女神ニンアルル
-- 效果：
-- 魔法师族4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以自己墓地1只4星以上的魔法师族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：有这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡装备中的场合，以自己的魔法与陷阱区域1张「大贤者」卡和对方场上1张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c8660395.initial_effect(c)
	-- 设置XYZ召唤手续：魔法师族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己墓地1只4星以上的魔法师族怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8660395,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,8660395)
	e1:SetCost(c8660395.thcost)
	e1:SetTarget(c8660395.thtg)
	e1:SetOperation(c8660395.thop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡装备中的场合，以自己的魔法与陷阱区域1张「大贤者」卡和对方场上1张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8660395,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,8660396)
	e3:SetCondition(c8660395.descon)
	e3:SetTarget(c8660395.destg)
	e3:SetOperation(c8660395.desop)
	c:RegisterEffect(e3)
end
-- ①号效果的Cost：把这张卡1个超量素材取除
function c8660395.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤自己墓地4星以上的魔法师族且可以加入手卡的怪兽
function c8660395.thfilter(c)
	return c:IsLevelAbove(4) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- ①号效果的Target：检查并选择自己墓地1只4星以上的魔法师族怪兽作为对象，并设置操作信息为加入手卡
function c8660395.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8660395.thfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的、可作为效果对象的4星以上魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c8660395.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8660395.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①号效果的Operation：将作为对象的怪兽加入手卡
function c8660395.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③号效果的发动条件：这张卡作为装备卡装备中
function c8660395.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 过滤自己魔法与陷阱区域表侧表示的「大贤者」卡
function c8660395.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150) and c:GetSequence()<5
end
-- ③号效果的Target：检查并选择自己魔陷区1张「大贤者」卡和对方场上1张魔法·陷阱卡作为对象，并设置操作信息为破坏
function c8660395.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己魔法与陷阱区域是否存在满足条件的「大贤者」卡
	if chk==0 then return Duel.IsExistingTarget(c8660395.desfilter,tp,LOCATION_SZONE,0,1,nil)
		-- 并且检查对方场上是否存在魔法·陷阱卡
		and Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己魔法与陷阱区域1张「大贤者」卡作为效果对象
	local g=Duel.SelectTarget(tp,c8660395.desfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	g:Merge(g2)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ③号效果的Operation：将作为对象的卡片破坏
function c8660395.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍对该效果有效的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 破坏这些卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
