--エヴォルカイザー・ラーズ
-- 效果：
-- 6星怪兽×2
-- ①：对方不能把持有超量素材的这张卡作为怪兽的效果的对象。
-- ②：对方把卡的效果发动时，把这张卡2个超量素材取除，以对方场上1张表侧表示卡为对象才能发动（这张卡只有爬虫类族·恐龙族怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个）。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化效果函数，设置该卡的召唤限制并添加超量召唤手续，注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加等级为6、需要2只怪兽作为素材的超量召唤手续
	aux.AddXyzProcedure(c,nil,6,2)
	-- ①：对方不能把持有超量素材的这张卡作为怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.prcon)
	e1:SetValue(s.prval)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时，把这张卡2个超量素材取除，以对方场上1张表侧表示卡为对象才能发动（这张卡只有爬虫类族·恐龙族怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个）。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 条件函数：判断该卡是否具有超量素材
function s.prcon(e)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0
end
-- 值函数：判断是否为对方怪兽效果
function s.prval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- 条件函数：判断是否为对方发动效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 费用函数：扣除超量素材，若满足条件则只扣除1个
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local ct=2
	-- 判断是否含有非爬虫类族或非恐龙族的超量素材
	if not g:IsExists(aux.NOT(Card.IsRace),1,nil,RACE_REPTILE+RACE_DINOSAUR) then
		ct=1
	end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	c:RemoveOverlayCard(tp,ct,2,REASON_COST)
end
-- 目标选择函数：选择对方场上一张可无效的卡
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 目标过滤函数：判断目标是否为对方场上表侧表示的卡
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 效果处理函数：使目标卡效果无效并设置其在回合结束时重置
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local c=e:GetHandler()
		-- 使目标卡效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
