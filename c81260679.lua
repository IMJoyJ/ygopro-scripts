--オオヒメの御巫
-- 效果：
-- 「御巫神乐」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「大日女之御巫」以外的1张「御巫」卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ③：自己·对方回合，以自己墓地1张装备魔法卡为对象才能发动。那张卡给可以装备的场上1只怪兽装备。
function c81260679.initial_effect(c)
	aux.AddCodeList(c,16310544)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「大日女之御巫」以外的1张「御巫」卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81260679,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81260679)
	e1:SetCost(c81260679.thcost)
	e1:SetTarget(c81260679.thtg)
	e1:SetOperation(c81260679.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合，以自己墓地1张装备魔法卡为对象才能发动。那张卡给可以装备的场上1只怪兽装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(81260679,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,81260680)
	e4:SetTarget(c81260679.eqtg)
	e4:SetOperation(c81260679.eqop)
	c:RegisterEffect(e4)
end
-- ①效果的发动代价：将手牌的这张卡给对方观看
function c81260679.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤卡组中「大日女之御巫」以外的「御巫」卡
function c81260679.thfilter(c)
	return c:IsSetCard(0x18d) and not c:IsCode(81260679) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组中是否存在可检索的卡，并设置检索和丢弃手牌的操作信息
function c81260679.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「大日女之御巫」以外的「御巫」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81260679.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- ①效果的处理：从卡组将1张「大日女之御巫」以外的「御巫」卡加入手牌，之后丢弃1张手牌
function c81260679.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「大日女之御巫」以外的「御巫」卡
	local g=Duel.SelectMatchingCard(tp,c81260679.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使后续的丢弃手牌处理不与加入手牌同时处理
		Duel.BreakEffect()
		-- 让玩家选择并丢弃1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤墓地中可以装备给场上怪兽的装备魔法卡
function c81260679.filter(c,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查场上是否存在可以装备该装备魔法卡的怪兽
		and Duel.GetMatchingGroupCount(c81260679.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)>0
end
-- 过滤场上表侧表示且可以装备该装备魔法卡的怪兽
function c81260679.eqfilter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
-- ③效果的发动准备：进行取对象判定，检查魔法与陷阱区域是否有空位，以及墓地中是否存在符合条件的装备魔法卡
function c81260679.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81260679.filter(chkc,tp) end
	-- 检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以装备给场上怪兽的装备魔法卡
		and Duel.IsExistingTarget(c81260679.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1张装备魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,c81260679.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置卡片离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的处理：将作为对象的墓地的装备魔法卡装备给场上1只可以装备的怪兽
function c81260679.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	-- 获取场上所有可以装备该装备魔法卡的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c81260679.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	-- 检查魔法与陷阱区域是否有空位、场上是否有可装备的怪兽，以及作为对象的装备魔法卡是否仍适用该效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetCount()>0 and tc:IsRelateToEffect(e) then
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将该装备魔法卡装备给选择的怪兽
		Duel.Equip(tp,tc,sg:GetFirst())
	end
end
