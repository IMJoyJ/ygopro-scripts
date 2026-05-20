--スプリガンズ・バンガー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
-- ②：从自己墓地把「护宝炮妖·爆竹」以外的1只「护宝炮妖」怪兽和这张卡除外才能发动。从卡组把1张「护宝炮妖」卡加入手卡。
function c83203672.initial_effect(c)
	-- ①：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83203672,0))  --"补充超量素材"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCountLimit(1,83203672)
	e1:SetTarget(c83203672.ovtg)
	e1:SetOperation(c83203672.ovop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把「护宝炮妖·爆竹」以外的1只「护宝炮妖」怪兽和这张卡除外才能发动。从卡组把1张「护宝炮妖」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83203672,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,83203673)
	e2:SetCost(c83203672.thcost)
	e2:SetTarget(c83203672.thtg)
	e2:SetOperation(c83203672.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「护宝炮妖」超量怪兽
function c83203672.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- ①号效果的发动判定与对象选择
function c83203672.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83203672.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在可以作为对象的「护宝炮妖」超量怪兽，且自身可以作为超量素材
	if chk==0 then return Duel.IsExistingTarget(c83203672.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「护宝炮妖」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c83203672.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若此卡在墓地发动，则设置涉及墓地卡片离地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ①号效果的处理：将自身作为超量素材
function c83203672.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay() then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 若自身原本拥有超量素材，则将那些素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将这张卡重叠作为该超量怪兽的超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 过滤条件：自己墓地「护宝炮妖·爆竹」以外的「护宝炮妖」怪兽
function c83203672.costfilter(c)
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and not c:IsCode(83203672) and c:IsAbleToRemoveAsCost()
end
-- ②号效果的发动代价处理
function c83203672.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身以及墓地另一只「护宝炮妖」怪兽是否能作为代价除外
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c83203672.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地1只「护宝炮妖·爆竹」以外的「护宝炮妖」怪兽
	local g=Duel.SelectMatchingCard(tp,c83203672.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和这张卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的「护宝炮妖」卡片
function c83203672.thfilter(c)
	return c:IsSetCard(0x155) and c:IsAbleToHand()
end
-- ②号效果的发动判定与检索准备
function c83203672.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的「护宝炮妖」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c83203672.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理：从卡组检索「护宝炮妖」卡片
function c83203672.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「护宝炮妖」卡片
	local g=Duel.SelectMatchingCard(tp,c83203672.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
