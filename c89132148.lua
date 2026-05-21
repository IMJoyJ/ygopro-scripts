--フォトン・オービタル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只「光子」怪兽或「银河」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
-- ●装备怪兽的攻击力上升500，不会被战斗破坏。
-- ②：把装备的这张卡送去墓地才能发动。除「光子轨道」外的1只「光子」怪兽或「银河」怪兽从卡组加入手卡。
function c89132148.initial_effect(c)
	-- ①：以自己场上1只「光子」怪兽或「银河」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89132148,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c89132148.eqtg)
	e1:SetOperation(c89132148.eqop)
	c:RegisterEffect(e1)
	-- ②：把装备的这张卡送去墓地才能发动。除「光子轨道」外的1只「光子」怪兽或「银河」怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89132148,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,89132148)
	e2:SetCondition(c89132148.thcon)
	e2:SetCost(c89132148.thcost)
	e2:SetTarget(c89132148.thtg)
	e2:SetOperation(c89132148.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选场上表侧表示的「光子」或「银河」怪兽
function c89132148.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 装备效果的发动准备：检查魔陷区空位并选择自己场上的「光子」或「银河」怪兽作为对象
function c89132148.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and c89132148.filter(chkc) end
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在除自身以外的、满足过滤条件的怪兽
		and Duel.IsExistingTarget(c89132148.filter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只满足过滤条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c89132148.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 装备效果的处理：将自身作为装备卡装备给目标怪兽，并赋予其装备效果
function c89132148.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中选择的第一个对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位，以及对象怪兽是否仍表侧表示、仍是有效对象且在自己场上
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c89132148.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- ●装备怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 限制装备卡只能装备给作为对象的怪兽
function c89132148.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 检查这张卡当前是否有装备对象
function c89132148.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 检索效果的发动代价：检查并把装备的这张卡送去墓地
function c89132148.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把装备的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选卡组中除「光子轨道」外的「光子」或「银河」怪兽
function c89132148.thfilter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_MONSTER) and not c:IsCode(89132148) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的卡并设置操作信息
function c89132148.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在除「光子轨道」外的「光子」或「银河」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89132148.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组将1张符合条件的卡加入手卡并给对方确认
function c89132148.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c89132148.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
