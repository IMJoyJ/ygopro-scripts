--オオヒメの御巫
-- 效果：
-- 「御巫神乐」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「大日女之御巫」以外的1张「御巫」卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ③：自己·对方回合，以自己墓地1张装备魔法卡为对象才能发动。那张卡给可以装备的场上1只怪兽装备。
function c81260679.initial_effect(c)
	-- 记录此卡有关联的卡片密码（御巫神乐）
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
-- 发动代价：把手牌的这张卡给对方观看
function c81260679.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：从卡组把「大日女之御巫」以外可以加入手牌的「御巫」卡
function c81260679.thfilter(c)
	return c:IsSetCard(0x18d) and not c:IsCode(81260679) and c:IsAbleToHand()
end
-- 效果目标：检查卡组中是否存在符合条件的「御巫」卡，并设置加入手牌及丢弃手牌的操作信息
function c81260679.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「大日女之御巫」以外的「御巫」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81260679.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置将1张手牌丢弃的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：从卡组将1张「大日女之御巫」以外的「御巫」卡加入手牌，那之后从手牌中选1张卡丢弃
function c81260679.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「御巫」卡
	local g=Duel.SelectMatchingCard(tp,c81260679.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 对玩家的手牌进行洗牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理（使前后的效果处理不同时进行）
		Duel.BreakEffect()
		-- 从手牌中选择并丢弃1张卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤函数：墓地中可以装备给场上怪兽的装备魔法卡
function c81260679.filter(c,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 且场上存在可以装备该装备魔法卡的怪兽
		and Duel.GetMatchingGroupCount(c81260679.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)>0
end
-- 过滤函数：场上可以装备该卡且表侧表示的怪兽
function c81260679.eqfilter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
-- 效果目标：选择墓地的1张装备魔法卡作为效果的对象，并设置该卡离开墓地的操作信息
function c81260679.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81260679.filter(chkc,tp) end
	-- 检查自己魔法与陷阱区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且墓地中是否存在可以装备在场上怪兽上的装备魔法卡
		and Duel.IsExistingTarget(c81260679.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择墓地里的1张装备魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,c81260679.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置将墓地的装备魔法卡转移位置的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：将墓地作为对象的装备魔法卡给场上1只可以装备的怪兽装备
function c81260679.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为当前连锁对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	-- 获取场上所有符合该装备卡装备条件的怪兽
	local g=Duel.GetMatchingGroup(c81260679.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	-- 如果魔法与陷阱区域有空余、场上存在可装备该卡的怪兽，且对象卡仍然存在
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetCount()>0 and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要装备该装备卡的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将该装备卡装备给选中的怪兽
		Duel.Equip(tp,tc,sg:GetFirst())
	end
end
