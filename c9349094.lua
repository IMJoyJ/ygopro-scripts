--神樹獣ハイペリュトン
-- 效果：
-- 9星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己回合，自己把魔法·陷阱·怪兽的效果发动时，以和那个效果相同种类（怪兽·魔法·陷阱）的自己墓地1张卡为对象才能发动。把作为对象的卡在这张卡下面重叠作为超量素材。
-- ②：对方回合，魔法·陷阱·怪兽的效果发动时才能发动。和那个效果相同种类（怪兽·魔法·陷阱）的1个超量素材从这张卡取除，那个发动无效并破坏。
function c9349094.initial_effect(c)
	-- 设置该卡XYZ召唤的手续为：9星怪兽2只
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ①：自己回合，自己把魔法·陷阱·怪兽的效果发动时，以和那个效果相同种类（怪兽·魔法·陷阱）的自己墓地1张卡为对象才能发动。把作为对象的卡在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9349094,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9349094)
	e1:SetCondition(c9349094.ovcon)
	e1:SetTarget(c9349094.ovtg)
	e1:SetOperation(c9349094.ovop)
	c:RegisterEffect(e1)
	-- ②：对方回合，魔法·陷阱·怪兽的效果发动时才能发动。和那个效果相同种类（怪兽·魔法·陷阱）的1个超量素材从这张卡取除，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9349094,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9349095)
	e2:SetCondition(c9349094.negcon)
	e2:SetTarget(c9349094.negtg)
	e2:SetOperation(c9349094.negop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c9349094.ovcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己回合，且发动效果的玩家也是自己
	return Duel.GetTurnPlayer()==tp and rp==tp
end
-- 过滤墓地中与发动的效果相同种类（怪兽/魔法/陷阱）且可以作为超量素材的卡
function c9349094.ovfilter(c,typ)
	return c:IsType(typ) and c:IsCanOverlay()
end
-- 效果①的发动目标选择与合法性检测函数
function c9349094.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local typ=bit.band(re:GetActiveType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9349094.ovfilter(chkc,typ) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在至少1张与发动的效果相同种类的卡
		and Duel.IsExistingTarget(c9349094.ovfilter,tp,LOCATION_GRAVE,0,1,nil,typ) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1张与发动的效果相同种类的卡作为对象
	local g=Duel.SelectTarget(tp,c9349094.ovfilter,tp,LOCATION_GRAVE,0,1,1,nil,typ)
	-- 设置效果处理信息为：有1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果①的效果处理（重叠超量素材）函数
function c9349094.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取在发动时选择的作为对象的那张墓地的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将作为对象的卡重叠在这张卡下面作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 效果②的发动条件判定函数
function c9349094.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合，且被连锁的效果可以被无效，且自身未被战斗破坏
	return Duel.GetTurnPlayer()==1-tp and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的发动目标选择与合法性检测函数
function c9349094.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local typ=bit.band(re:GetActiveType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,typ)
	end
	-- 设置效果处理信息为：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息为：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的效果处理（取除素材、无效并破坏）函数
function c9349094.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	local typ=bit.band(re:GetActiveType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
	local og=e:GetHandler():GetOverlayGroup():Filter(Card.IsType,nil,typ)
	if og:GetCount()<=0 then return end
	-- 提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	local g=og:Select(tp,1,1,nil)
	-- 如果成功选择并把该超量素材送去墓地（即取除素材）
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		-- 触发“超量素材被取除”的单体时点
		Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 如果成功使该发动无效，且该卡在场上/效果处理时仍与效果相关联
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏该卡
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
