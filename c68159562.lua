--マドルチェ・プロムナード
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以对方场上1张表侧表示卡和自己的场上·墓地1只「魔偶甜点」怪兽为对象才能发动。那张对方的卡的效果直到回合结束时无效，那只自己怪兽回到手卡。
-- ②：把墓地的这张卡除外，以自己场上1只「魔偶甜点」超量怪兽为对象才能发动。从自己的手卡·卡组·墓地选1只「魔偶甜点」怪兽作为成为对象的怪兽的超量素材。
function c68159562.initial_effect(c)
	-- ①：以对方场上1张表侧表示卡和自己的场上·墓地1只「魔偶甜点」怪兽为对象才能发动。那张对方的卡的效果直到回合结束时无效，那只自己怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68159562,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,68159562)
	e1:SetTarget(c68159562.target)
	e1:SetOperation(c68159562.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「魔偶甜点」超量怪兽为对象才能发动。从自己的手卡·卡组·墓地选1只「魔偶甜点」怪兽作为成为对象的怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68159562,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,68159562)
	-- 把墓地的这张卡除外作为发动效果的cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c68159562.mattg)
	e2:SetOperation(c68159562.matop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示或墓地的「魔偶甜点」怪兽，且能回到手卡
function c68159562.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x71) and c:IsAbleToHand()
end
-- ①效果的发动准备与目标选择
function c68159562.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 检查对方场上是否存在可以无效的表侧表示卡
		return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己场上或墓地是否存在符合条件的「魔偶甜点」怪兽
		and Duel.IsExistingTarget(c68159562.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
	end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示卡作为对象
	local g1=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上或墓地1只「魔偶甜点」怪兽作为对象
	local g2=Duel.SelectTarget(tp,c68159562.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的自己怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- ①效果的处理：无效对方卡片的效果，并将自己的怪兽返回手卡
function c68159562.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁的所有对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp)
		and tc:IsCanBeDisabledByEffect(e) then
		-- 使与目标卡片相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张对方的卡的效果直到回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张对方的卡的效果直到回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张对方的卡的效果直到回合结束时无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		if lc:IsRelateToEffect(e) and lc:IsControler(tp) then
			-- 将作为对象的自己怪兽回到手卡
			Duel.SendtoHand(lc,nil,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己场上表侧表示的「魔偶甜点」超量怪兽
function c68159562.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x71)
end
-- 过滤条件：可以作为超量素材的「魔偶甜点」怪兽
function c68159562.matfilter(c,e)
	return c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end
-- ②效果的发动准备与目标选择
function c68159562.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c68159562.tgfilter(chkc) end
	-- 检查自己场上是否存在「魔偶甜点」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c68159562.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的手卡、卡组、墓地是否存在可以作为超量素材的「魔偶甜点」怪兽
		and Duel.IsExistingMatchingCard(c68159562.matfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「魔偶甜点」超量怪兽作为对象
	Duel.SelectTarget(tp,c68159562.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理：将选中的「魔偶甜点」怪兽作为超量素材叠放
function c68159562.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手卡、卡组、墓地选择1只「魔偶甜点」怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c68159562.matfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e)
		if g:GetCount()>0 then
			-- 将选中的怪兽作为超量素材重叠在目标怪兽下面
			Duel.Overlay(tc,g)
		end
	end
end
