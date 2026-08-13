--RR－グロリアス・ブライト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「急袭猛禽」怪兽存在的场合，以对方场上1只表侧表示怪兽为对象才能发动（自己场上有「急袭猛禽」超量怪兽存在的场合，也能作为代替以对方场上1张表侧表示卡为对象）。那张卡的效果直到回合结束时无效。
-- ②：把墓地的这张卡除外，以自己的墓地·除外状态的1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册该卡的两个效果：①为魔法卡发动时以对方场上表侧表示卡为对象将其效果无效的诱发效果；②为墓地中除外自身为代价，将1只自己的墓地·除外状态的「急袭猛禽」怪兽加入手卡的诱发即时效果；两者通过相同的CountLimit码（卡号）共享同名卡1回合1次的使用次数。
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
	-- 设置②效果的发动代价：把墓地里的这张卡除外（使用通用代价函数aux.bfgcost实现除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数s.filter：筛选表侧表示的「急袭猛禽」怪兽，用于判断①效果的发动条件。
function s.filter(c)
	return c:IsSetCard(0xba) and c:IsFaceup()
end
-- 定义过滤函数s.filter2：筛选表侧表示的「急袭猛禽」超量怪兽，用于判断①效果能否将对象扩大到对方场上任意表侧表示卡。
function s.filter2(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有表侧表示「急袭猛禽」怪兽存在。该条件在效果发动前检查。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区域是否存在至少1张满足s.filter的表侧表示「急袭猛禽」怪兽。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的取对象处理：若自己场上有「急袭猛禽」超量怪兽，则从对方场上选择1张表侧表示卡；否则从对方怪兽区域选择1只可无效的表侧效果怪兽；同时将选择结果写入无效化操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=nil
	-- 判断自己场上是否有表侧表示的「急袭猛禽」超量怪兽，以决定采用哪种对象选择分支。
	if Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil) then
		-- 对象合法性检查：当连锁中指定对象时，确认该卡是对方场上的表侧表示卡且可以被无效化。
		if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
		-- 效果发动时检查对方场上是否存在至少1张可被无效化的表侧表示卡，作为能否发动①的前提。
		if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
		-- 弹出“请选择要无效的卡”的提示信息，要求玩家选择对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从对方场上选择1张可无效的表侧表示卡作为①效果的对象（因有「急袭猛禽」超量怪兽，所以对象不限于怪兽）。
		g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	else
		-- 对象合法性检查：无「急袭猛禽」超量怪兽时，对象必须是对方怪兽区域中表侧表示且可无效的效果怪兽。
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
		-- 效果发动时检查对方怪兽区域是否存在至少1只可无效的表侧效果怪兽。
		if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
		-- 弹出“请选择要无效的卡”的提示信息，要求玩家选择对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从对方怪兽区域选择1只可无效的表侧效果怪兽作为①效果的对象。
		g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	end
	-- 将<无效卡>的操作信息登记到当前连锁中，表示效果处理时会使1张卡无效，供相关卡牌连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：若对象卡仍表侧表示且与效果有关联，则使对象卡效果直到回合结束时无效；若对象是陷阱怪兽，则另外赋予陷阱怪兽无效效果，并无效相关连锁。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使对象卡相关的连锁效果无效化，重置时点为变为里侧表示的场合。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 定义②效果的对象过滤器：选择自己墓地·除外状态的表侧表示「急袭猛禽」怪兽，且该卡可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsFaceupEx()
end
-- ②效果的取对象处理：从自己墓地·除外状态选择1只符合条件的「急袭猛禽」怪兽作为对象，并登记加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果发动时检查自己墓地·除外状态是否存在至少1只满足条件的「急袭猛禽」怪兽，作为能否发动②的前提。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 弹出“请选择要加入手牌的卡”的提示信息，要求玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的墓地·除外状态中选择1只符合条件的「急袭猛禽」怪兽作为②效果的对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 将<加入手卡>的操作信息登记到当前连锁中，表示效果处理时会1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：将对象怪兽加入其持有者手卡，并向对方玩家确认加入手卡的那张卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送去持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的卡，以确认其卡名等信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
