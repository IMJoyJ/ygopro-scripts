--SZW－天聖輝狼剣
-- 效果：
-- 这张卡召唤成功时，可以选择自己场上1只当作装备卡使用的名字带有「异热同心武器」的怪兽表侧守备表示特殊召唤。此外，自己的主要阶段时，手卡的这张卡可以当作装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。装备怪兽战斗破坏对方怪兽送去墓地时，可以选择自己墓地1只名字带有「异热同心武器」的怪兽加入手卡。
function c12927849.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己场上1只当作装备卡使用的名字带有「异热同心武器」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12927849,0))  --"特殊召唤"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c12927849.sptg)
	e1:SetOperation(c12927849.spop)
	c:RegisterEffect(e1)
	-- 此外，自己的主要阶段时，手卡的这张卡可以当作装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12927849,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(c12927849.eqtg)
	e2:SetOperation(c12927849.eqop)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏对方怪兽送去墓地时，可以选择自己墓地1只名字带有「异热同心武器」的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12927849,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c12927849.thcon)
	e3:SetTarget(c12927849.thtg)
	e3:SetOperation(c12927849.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：选择自己场上表侧表示且属于「异热同心武器」字段、能以表侧守备表示特殊召唤的怪兽。
function c12927849.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x107e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤的目标选择函数：先验证指定对象是否合法；在发动时检查自己场上是否有空位且存在符合条件的「异热同心武器」怪兽。
function c12927849.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c12927849.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否存在可用的空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上（魔陷区）是否存在满足filter条件的「异热同心武器」装备怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c12927849.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己魔陷区选择1只符合条件的「异热同心武器」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c12927849.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，宣告本连锁处理将进行特殊召唤，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤的处理函数：将选择的对象怪兽特殊召唤到场上。
function c12927849.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一张对象卡（即选择要特殊召唤的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上（不检查召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 装备对象的过滤条件：选择自己场上表侧表示且属于「希望皇 霍普」字段的怪兽。
function c12927849.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备的目标选择函数：验证指定对象合法，并检查自己魔陷区有空位且存在可装备的「希望皇 霍普」怪兽。
function c12927849.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12927849.eqfilter(chkc) end
	-- 检查自己魔陷区是否有可用的空格，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在满足eqfilter的「希望皇 霍普」怪兽，可作为装备对象。
		and Duel.IsExistingTarget(c12927849.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只「希望皇 霍普」怪兽作为装备对象。
	Duel.SelectTarget(tp,c12927849.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备的处理函数：若装备条件满足则执行装备，否则将这张卡送去墓地。
function c12927849.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得当前连锁中记录的对象卡（要装备的「希望皇 霍普」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查装备是否仍合法：魔陷区有空位、对象未变为对方控制且表侧表示、且与效果相关；若任一条件不满足则准备送去墓地。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备无法进行时，将手牌的这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c12927849.zw_equip_monster(c,tp,tc)
end
-- 装备并附加装备限制的处理函数：尝试装备成功并给这张卡设置只能装备给该对象的限制。
function c12927849.zw_equip_monster(c,tp,tc)
	-- 执行装备操作，将这张卡装备给目标怪兽；若装备失败则终止后续处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 手卡的这张卡可以当作装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c12927849.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数：判断尝试装备的对象是否为当初选定的那只「希望皇 霍普」怪兽，即此装备卡只能装备给该怪兽。
function c12927849.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 触发条件：装备这张卡的怪兽与对方怪兽战斗并将其破坏送去墓地时，满足发动条件（该怪兽为装备对象、战斗对象在墓地且为怪兽）。
function c12927849.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return ec==e:GetHandler():GetEquipTarget() and ec:IsStatus(STATUS_OPPO_BATTLE) and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 墓地卡片过滤条件：选择属于「异热同心武器」字段的怪兽卡，且可以被加入手卡。
function c12927849.thfilter(c)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 加入手卡的目标选择函数：验证指定对象合法，并检查墓地中存在符合条件的「异热同心武器」怪兽。
function c12927849.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12927849.thfilter(chkc) end
	-- 检查自己墓地中是否存在满足thfilter的「异热同心武器」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c12927849.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的「异热同心武器」怪兽作为对象。
	local g=Duel.SelectTarget(tp,c12927849.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，宣告本连锁处理将进行加入手卡，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 加入手卡的处理函数：将对象卡加入持有者手卡并向对方确认。
function c12927849.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡（要加入手卡的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，原因记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手卡的卡，以确认操作。
		Duel.ConfirmCards(1-tp,tc)
	end
end
