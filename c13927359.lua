--RR－グロリアス・ブライト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「急袭猛禽」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有「急袭猛禽」超量怪兽存在的场合，也能作为代替以对方场上1张表侧表示卡为对象）。那张卡的效果直到回合结束时无效。
-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：自己场上有「急袭猛禽」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有「急袭猛禽」超量怪兽存在的场合，也能作为代替以对方场上1张表侧表示卡为对象）。那张卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 筛选场上表侧表示的急袭猛禽怪兽
function s.filter(c)
	return c:IsSetCard(0xba) and c:IsFaceup()
end
-- 筛选场上表侧表示的急袭猛禽超量怪兽
function s.filter2(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 判断是否满足效果①发动条件
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在急袭猛禽怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果①的目标选择函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=nil
	-- 检查自己场上是否存在急袭猛禽超量怪兽
	if Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil) then
		-- 判断目标是否为对方场上的卡且可被无效
		if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
		-- 检查是否存在可作为无效对象的对方场上卡
		if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		-- 选择对方场上的1张卡作为无效对象
		g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	else
		-- 判断目标是否为对方场上的怪兽且可被无效
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
		-- 检查是否存在可作为无效对象的对方场上怪兽
		if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
		-- 提示玩家选择要无效的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		-- 选择对方场上的1只怪兽作为无效对象
		g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	end
	-- 设置效果①的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 设置效果①的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽无法发动效果
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 筛选墓地或除外状态的急袭猛禽怪兽
function s.thfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsFaceupEx()
end
-- 设置效果②的目标选择函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否存在可作为效果②对象的墓地或除外状态的急袭猛禽怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择墓地或除外状态的1只急袭猛禽怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果②的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果②的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认被加入手卡的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
