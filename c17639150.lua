--機殻の生贄
-- 效果：
-- 「机壳」怪兽才能装备。
-- ①：装备怪兽的攻击力上升300，不会被战斗破坏。
-- ②：「机壳」怪兽上级召唤的场合，装备怪兽可以作为2只的数量解放。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只「机壳」怪兽加入手卡。
function c17639150.initial_effect(c)
	-- 「机壳」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c17639150.eqtg)
	e1:SetOperation(c17639150.eqop)
	c:RegisterEffect(e1)
	-- 「机壳」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c17639150.effcon)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 不会被战斗破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 「机壳」怪兽上级召唤的场合，装备怪兽可以作为2只的数量解放。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e5:SetValue(c17639150.effcon)
	c:RegisterEffect(e5)
	-- 这张卡从场上送去墓地的场合才能发动。从卡组把1只「机壳」怪兽加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(17639150,0))  --"卡组检索"
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCondition(c17639150.thcon)
	e6:SetTarget(c17639150.thtg)
	e6:SetOperation(c17639150.thop)
	c:RegisterEffect(e6)
end
-- 检查卡片是否属于「机壳」系列（0xaa），用于装备对象限制及作为2只解放的判定。
function c17639150.effcon(e,c)
	return c:IsSetCard(0xaa)
end
-- 筛选场上表侧表示且属于「机壳」系列的怪兽，作为装备对象的选择条件。
function c17639150.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa)
end
-- 装备魔法发动时的处理：检查是否存在符合条件的对象，选择1只表侧表示「机壳」怪兽作为装备对象，并设置此操作将进行装备。
function c17639150.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c17639150.eqfilter(chkc) end
	-- 在效果发动时检查场上是否存在至少1只符合条件的表侧表示「机壳」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c17639150.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的提示消息，用于装备对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示「机壳」怪兽，并将其设为效果的对象。
	Duel.SelectTarget(tp,c17639150.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的处理信息为“装备”分类，目标为本卡，数量为1，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若本卡和对象怪兽仍与效果关联且对象表侧表示，则把本卡装备给那只怪兽。
function c17639150.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡由玩家tp装备给选中的怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 检查这张卡从场上送去墓地，满足③的发动条件。
function c17639150.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选卡组中属于「机壳」系列且为怪兽卡、可以加入手卡的卡。
function c17639150.thfilter(c)
	return c:IsSetCard(0xaa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时检查卡组是否存在符合条件的「机壳」怪兽，并设置操作信息为从卡组加入手卡。
function c17639150.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查卡组是否存在至少1只符合条件的「机壳」怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17639150.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“加入手卡”分类，对象不确定（nil），预计从卡组处理1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，让玩家从卡组选择1只符合条件的「机壳」怪兽加入手卡，并让对方确认。
function c17639150.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的「机壳」怪兽。
	local g=Duel.SelectMatchingCard(tp,c17639150.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
