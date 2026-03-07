--オルターガイスト・マテリアリゼーション
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只「幻变骚灵」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。这张卡离开场上时那只怪兽破坏。
-- ②：把墓地的这张卡除外，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
function c35146019.initial_effect(c)
	-- 效果①：以自己墓地1只「幻变骚灵」怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡当作装备卡使用给那只怪兽装备。这张卡离开场上时那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c35146019.cost)
	e1:SetTarget(c35146019.target)
	e1:SetOperation(c35146019.operation)
	c:RegisterEffect(e1)
	-- 效果②：把墓地的这张卡除外，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetOperation(c35146019.checkop)
	c:RegisterEffect(e0)
	-- 这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c35146019.desop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	-- 把墓地的这张卡除外，以自己墓地1张「幻变骚灵」陷阱卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,35146019)
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c35146019.thtg)
	e3:SetOperation(c35146019.thop)
	c:RegisterEffect(e3)
end
-- 设置效果①的发动条件，包括确保此卡在场上停留并防止连锁被无效
function c35146019.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在场上停留的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁被无效时的处理效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c35146019.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 处理连锁被无效时的逻辑，如果连锁ID匹配则取消此卡进入墓地
function c35146019.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤满足条件的「幻变骚灵」怪兽
function c35146019.spfilter(c,e,tp)
	return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 判断是否满足效果①的发动条件
function c35146019.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35146019.spfilter(chkc,e,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 判断场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在墓地存在满足条件的「幻变骚灵」怪兽
		and Duel.IsExistingTarget(c35146019.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的「幻变骚灵」怪兽
	local g=Duel.SelectTarget(tp,c35146019.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果①的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果①的装备操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制效果的过滤函数
function c35146019.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 执行效果①的处理，包括特殊召唤和装备
function c35146019.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效并进行特殊召唤
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将此卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 设置装备限制效果
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
-- 检查此卡是否被无效
function c35146019.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当此卡离开场上时，若未被无效则破坏装备的怪兽
function c35146019.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤满足条件的「幻变骚灵」陷阱卡
function c35146019.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x103) and c:IsAbleToHand()
end
-- 设置效果②的发动条件
function c35146019.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35146019.thfilter(chkc) end
	-- 判断是否在墓地存在满足条件的「幻变骚灵」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c35146019.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的「幻变骚灵」陷阱卡
	local g=Duel.SelectTarget(tp,c35146019.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果②的加入手牌操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果②的处理，将陷阱卡加入手牌
function c35146019.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标陷阱卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标陷阱卡是否有效并加入手牌
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标陷阱卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
