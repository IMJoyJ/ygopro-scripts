--黒鋼竜
-- 效果：
-- ①：以自己场上1只「真红眼」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升600的装备魔法卡使用给那只自己怪兽装备。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「真红眼」卡加入手卡。
function c93969023.initial_effect(c)
	-- ①：以自己场上1只「真红眼」怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力上升600的装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c93969023.eqtg)
	e1:SetOperation(c93969023.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「真红眼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c93969023.thcon)
	e2:SetTarget(c93969023.thtg)
	e2:SetOperation(c93969023.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「真红眼」怪兽
function c93969023.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end
-- 效果①的发动准备：检查魔陷区空位并选择自己场上1只表侧表示的「真红眼」怪兽作为对象
function c93969023.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c93969023.filter(chkc) end
	-- 发动判定：检查自己魔陷区是否有空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动判定：检查自己场上是否存在除自身以外的、满足条件的「真红眼」怪兽作为对象
		and Duel.IsExistingTarget(c93969023.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「真红眼」怪兽作为效果对象
	Duel.SelectTarget(tp,c93969023.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将自身装备给目标怪兽，并适用攻击力上升及装备限制效果
function c93969023.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中选择的第一个对象（即要装备的「真红眼」怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位，以及对象怪兽是否仍满足装备条件（在自己场上、表侧表示、仍与效果相关联）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 当作装备魔法卡使用给那只自己怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(tc)
	e1:SetValue(c93969023.eqlimit)
	c:RegisterEffect(e1)
	-- 攻击力上升600
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制：只能装备给作为对象的那只怪兽
function c93969023.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的发动条件：这张卡必须是从场上送去墓地
function c93969023.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中可以加入手牌的「真红眼」卡片
function c93969023.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的「真红眼」卡片并设置操作信息
function c93969023.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：检查卡组中是否存在至少1张满足条件的「真红眼」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c93969023.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1张「真红眼」卡片加入手牌并给对方确认
function c93969023.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「真红眼」卡片
	local g=Duel.SelectMatchingCard(tp,c93969023.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
