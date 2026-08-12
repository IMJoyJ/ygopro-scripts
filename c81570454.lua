--焔聖騎士－ローラン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，这张卡在手卡存在的场合，以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备魔法卡使用给那只自己怪兽装备。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把「焰圣骑士-罗兰」以外的1只战士族·炎属性怪兽或1张装备魔法卡加入手卡。
function c81570454.initial_effect(c)
	-- ①：自己·对方回合，这张卡在手卡存在的场合，以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作攻击力上升500的装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81570454,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81570454)
	-- 设置效果在伤害步骤中，只有在伤害计算前才能发动（限制伤害计算后不能发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c81570454.eqtg)
	e1:SetOperation(c81570454.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c81570454.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把「焰圣骑士-罗兰」以外的1只战士族·炎属性怪兽或1张装备魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81570454,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,81570455)
	e3:SetCondition(c81570454.thcon)
	e3:SetTarget(c81570454.thtg)
	e3:SetOperation(c81570454.thop)
	c:RegisterEffect(e3)
end
-- 装备效果的靶向判定与目标选择：检查魔法与陷阱区域是否有空位，以及场上是否存在可以作为对象的表侧表示怪兽。
function c81570454.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自身魔法与陷阱区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择自己场上1只表侧表示的怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的执行：将手牌中的这张卡作为装备卡装备给目标怪兽，并适用攻击力上升500的效果。
function c81570454.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取本次效果发动的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷格是否已满、目标怪兽是否变成里侧表示、是否已离开场上或控制权发生转移。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		-- 若无法装备，则将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 给那只自己怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c81570454.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制：该装备卡只能装备给作为效果对象的那只怪兽。
function c81570454.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 在这张卡被送去墓地时，给这张卡注册一个在回合结束前有效的标记，用于记录送墓状态。
function c81570454.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(81570454,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检索效果的发动条件：检查这张卡在本回合内是否曾被送去墓地（是否存在送墓标记）。
function c81570454.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(81570454)>0
end
-- 检索过滤条件：卡组中「焰圣骑士-罗兰」以外的1只战士族·炎属性怪兽或1张装备魔法卡。
function c81570454.thfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)) or c:IsType(TYPE_EQUIP)) and not c:IsCode(81570454) and c:IsAbleToHand()
end
-- 检索效果的靶向判定：检查卡组中是否存在满足条件的卡，并设置检索的操作信息。
function c81570454.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c81570454.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1张满足条件的卡加入手牌并给对方确认。
function c81570454.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c81570454.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
