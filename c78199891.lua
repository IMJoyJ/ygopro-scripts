--御巫かみくらべ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「御巫」怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。把1张那只怪兽可以装备的装备魔法卡从卡组给那只怪兽装备。
-- ②：这张卡在墓地存在的状态，装备魔法卡被送去自己墓地的场合，把这张卡除外，以自己墓地1张装备魔法卡为对象才能发动。那张卡加入手卡。
function c78199891.initial_effect(c)
	-- ①：自己场上有「御巫」怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。把1张那只怪兽可以装备的装备魔法卡从卡组给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78199891,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,78199891)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c78199891.condition)
	e1:SetTarget(c78199891.target)
	e1:SetOperation(c78199891.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，装备魔法卡被送去自己墓地的场合，把这张卡除外，以自己墓地1张装备魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78199891,1))  --"回收装备魔法卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,78199892)
	e2:SetCondition(c78199891.thcon)
	-- 把这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c78199891.thtg)
	e2:SetOperation(c78199891.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「御巫」怪兽
function c78199891.cfilter(c)
	return c:IsSetCard(0x18d) and c:IsFaceup()
end
-- ①号效果的发动条件：自己场上存在表侧表示的「御巫」怪兽
function c78199891.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「御巫」怪兽
	return Duel.IsExistingMatchingCard(c78199891.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：场上表侧表示，且卡组中存在可以装备给该怪兽的装备魔法卡的怪兽
function c78199891.filter(c,tp)
	return c:IsFaceup()
		-- 检查卡组中是否存在至少1张可以装备给该怪兽的装备魔法卡
		and Duel.IsExistingMatchingCard(c78199891.eqfilter,tp,LOCATION_DECK,0,1,nil,tp,c)
end
-- 过滤条件：卡组中可以装备给目标怪兽的装备魔法卡
function c78199891.eqfilter(c,tp,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and c:CheckEquipTarget(ec)
end
-- ①号效果的对象选择阶段，检查并选择场上1只表侧表示怪兽作为对象
function c78199891.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c78199891.filter(chkc,tp) end
	if chk==0 then
		-- 获取自己魔陷区的可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 检查魔陷区是否有空位，且场上是否存在可以作为对象的怪兽
		return ft>0 and Duel.IsExistingTarget(c78199891.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c78199891.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- ①号效果的处理阶段：从卡组给对象怪兽装备1张合适的装备魔法卡
function c78199891.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍存在于场上且表侧表示，并确认自己魔陷区仍有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组选择1张可以装备给该怪兽的装备魔法卡
		local sc=Duel.SelectMatchingCard(tp,c78199891.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp,tc):GetFirst()
		if sc then
			-- 将选择的装备魔法卡装备给对象怪兽
			Duel.Equip(tp,sc,tc)
		end
	end
end
-- 过滤条件：送去自己墓地的装备魔法卡
function c78199891.ctfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_EQUIP)
end
-- ②号效果的发动条件：装备魔法卡被送去自己墓地，且送去墓地的卡不含此卡自身
function c78199891.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c78199891.ctfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：自己墓地可以加入手牌的装备魔法卡
function c78199891.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- ②号效果的对象选择阶段，选择自己墓地1张装备魔法卡作为对象
function c78199891.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c78199891.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的装备魔法卡
	if chk==0 then return Duel.IsExistingTarget(c78199891.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张装备魔法卡作为对象
	local g=Duel.SelectTarget(tp,c78199891.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为“将选中的1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②号效果的处理阶段：将作为对象的装备魔法卡加入手牌
function c78199891.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的装备魔法卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
