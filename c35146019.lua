--オルターガイスト・マテリアリゼーション
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只「幻变骚灵」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。这张卡离开场上时那只怪兽破坏。
-- ②：把墓地的这张卡除外，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
function c35146019.initial_effect(c)
	-- ①：以自己墓地1只「幻变骚灵」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。这张卡离开场上时那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c35146019.cost)
	e1:SetTarget(c35146019.target)
	e1:SetOperation(c35146019.operation)
	c:RegisterEffect(e1)
	-- 这张卡离开场上时那只怪兽破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetOperation(c35146019.checkop)
	c:RegisterEffect(e0)
	-- 这张卡离开场上时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c35146019.desop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,35146019)
	-- 将墓地中的这张卡除外作为发动②效果的费用。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c35146019.thtg)
	e3:SetOperation(c35146019.thop)
	c:RegisterEffect(e3)
end
-- ①效果发动时的代价处理：实际不支付卡牌代价，但给这张卡附加留在场上的效果，并注册一个监听本连锁被无效的持续效果，防止这张卡在①处理前因规则送入墓地，从而保证其后续能作为装备卡装备。
function c35146019.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID，用于后续判断该连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 把这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只「幻变骚灵」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。这张卡离开场上时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c35146019.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监听连锁被无效的持续效果注册到场上（由tp控制），使这张卡在①效果发动被无效时能够从墓地回到场上。
	Duel.RegisterEffect(e2,tp)
end
-- 当之前发动的①效果所在连锁被无效时，若这张卡仍与该连锁相关，则将它从墓地送回场上，避免它因魔法陷阱卡发动被无效而错误地留在墓地。
function c35146019.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的那个连锁的ID，并与之前保存的当前连锁ID比较，以确认被无效的是否是本效果的连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- ①效果的目标过滤条件：墓地中的「幻变骚灵」怪兽，且能够被效果特殊召唤为表侧攻击表示。
function c35146019.spfilter(c,e,tp)
	return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果发动时的对象选择与合法性检查：确认自己墓地存在可特殊召唤的「幻变骚灵」怪兽且自己主要怪兽区有空位，然后选择1只作为对象，并设置特殊召唤与装备的操作信息。
function c35146019.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35146019.spfilter(chkc,e,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区是否有空位，用于特殊召唤目标怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只可以成为效果对象且满足特殊召唤条件的「幻变骚灵」怪兽。
		and Duel.IsExistingTarget(c35146019.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示文字，用于选择目标时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「幻变骚灵」怪兽作为效果对象，并将该对象登记到当前连锁。
	local g=Duel.SelectTarget(tp,c35146019.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本效果将要把对象怪兽特殊召唤，供其他卡进行对应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，声明本效果将要把这张卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制函数：只有这张卡通过①效果装备的那只怪兽（以LabelObject记录）才能成为这张卡的装备对象。
function c35146019.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- ①效果处理：先将对象怪兽表侧攻击表示特殊召唤；若成功且这张卡仍与效果相关且未被规则送墓，则把这张卡装备给该怪兽并添加装备限制；若条件不满足则让这张卡取消送去墓地而留在场上。
function c35146019.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的对象卡（即选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽仍与效果相关、不受王家长眠之谷影响，并尝试以表侧攻击表示特殊召唤；若特殊召唤成功则继续装备处理。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡作为装备卡装备到特殊召唤成功的怪兽上。
			Duel.Equip(tp,c,tc)
			-- 把这张卡当作装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c35146019.eqlimit)
			e1:SetLabelObject(tc)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 在离场前检查这张卡的效果是否被无效，若是则标记为1，否则标记为0，用于后续决定离开场上时是否破坏装备怪兽。
function c35146019.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 这张卡离开场上时，若其效果未被无效（标签为0），则破坏这张卡装备的那只怪兽。
function c35146019.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏那只被装备的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的目标过滤条件：自己墓地1张「幻变骚灵」陷阱卡，且能够加入手牌。
function c35146019.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x103) and c:IsAbleToHand()
end
-- ②效果发动时的对象选择与合法性检查：确认自己墓地存在1张可加入手牌的「幻变骚灵」陷阱卡，选择1张作为对象，并设置加入手卡的操作信息。
function c35146019.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35146019.thfilter(chkc) end
	-- 检查自己墓地是否存在1张满足条件的「幻变骚灵」陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c35146019.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张「幻变骚灵」陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c35146019.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，声明本效果将把对象卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若对象卡仍与效果相关且不受王家长眠之谷影响，则将其加入持有者的手牌。
function c35146019.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡（墓地的那张陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果相关且不受王家长眠之谷影响，才能执行加入手牌。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象陷阱卡加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
