--甲虫装機の魔剣 ゼクトキャリバー
-- 效果：
-- 名字带有「甲虫装机」的怪兽才能装备。装备怪兽的攻击力·守备力上升800。场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「甲虫装机」的怪兽加入手卡。
function c16550875.initial_effect(c)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c16550875.target)
	e1:SetOperation(c16550875.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 名字带有「甲虫装机」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c16550875.eqlimit)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「甲虫装机」的怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16550875,0))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c16550875.thcon)
	e4:SetTarget(c16550875.thtg)
	e4:SetOperation(c16550875.thop)
	c:RegisterEffect(e4)
end
-- 装备对象限制：仅限名字带有「甲虫装机」的怪兽才能装备这张卡。
function c16550875.eqlimit(e,c)
	return c:IsSetCard(0x56)
end
-- 用于选择装备对象的过滤条件：表侧表示且名字带有「甲虫装机」的怪兽。
function c16550875.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 发动时的目标选择处理：确认存在合法装备对象，选择1只表侧表示的「甲虫装机」怪兽，并登记装备操作信息。
function c16550875.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16550875.filter(chkc) end
	-- 发动时确认场上是否存在至少1只表侧表示且名字带有「甲虫装机」的怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c16550875.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示发动玩家选择要装备的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从玩家场上选择1只表侧表示的名字带有「甲虫装机」的怪兽作为此卡装备的对象。
	Duel.SelectTarget(tp,c16550875.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息登记为装备效果，对象为此卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若此卡和目标怪兽均与效果保持关联且目标仍表侧表示，则将这张卡装备给目标怪兽。
function c16550875.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时所选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备到目标怪兽身上。
		Duel.Equip(tp,c,tc)
	end
end
-- 诱发条件：这张卡在场上表侧表示的状态下被送去墓地（此前位于场上且表侧表示）。
function c16550875.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择加入手卡的过滤条件：名字带有「甲虫装机」的怪兽卡，且能够加入手卡。
function c16550875.thfilter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 墓地回收效果的发动时处理：确认墓地存在合法对象，选择1只「甲虫装机」怪兽并登记加入手卡的操作信息。
function c16550875.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16550875.thfilter(chkc) end
	-- 发动时确认自己墓地是否存在至少1张名字带有「甲虫装机」的怪兽卡可以选择。
	if chk==0 then return Duel.IsExistingTarget(c16550875.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示发动玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的名字带有「甲虫装机」的怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,c16550875.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将本次连锁的操作信息登记为回手牌效果，对象为所选择的卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时取得对象卡，若仍与效果关联则将其加入持有者手卡，并向对方展示。
function c16550875.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该诱发效果所选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽卡送到其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
