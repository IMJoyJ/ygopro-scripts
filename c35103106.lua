--エヴォルカイザー・ラーズ
-- 效果：
-- 6星怪兽×2
-- ①：对方不能把持有超量素材的这张卡作为怪兽的效果的对象。
-- ②：对方把卡的效果发动时，把这张卡2个超量素材取除，以对方场上1张表侧表示卡为对象才能发动（这张卡只有爬虫类族·恐龙族怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个）。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片效果：启用召唤限制，添加6星怪兽×2的XYZ召唤手续；并注册①的‘持有超量素材时不受对方怪兽效果对象’永续效果和②的‘对方发动卡的效果时取除超量素材无效对方场上表侧表示卡效果’诱发即时效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：用任意2只6星怪兽叠放来XYZ召唤这张卡。
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
-- ①效果的适用条件：这张卡持有超量素材。
function s.prcon(e)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0
end
-- ①效果的具体免疫值：仅当效果发动者是对方玩家且该效果为怪兽效果时，持有超量素材的这张卡不能成为其效果对象。
function s.prval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动条件：检测到对方玩家发动了卡的效果（rp==1-tp）。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ②效果的代价处理：取除这张卡的2个超量素材；若其超量素材中没有‘不是爬虫类族·恐龙族’的怪兽（即所有素材均为爬虫类族或恐龙族），则取除数量改为1。该函数同时进行可发动检查和实际取除。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local ct=2
	-- 判断超量素材组中是否存在‘不是爬虫类族·恐龙族’的怪兽；若不存在，说明所有素材都属于爬虫类族或恐龙族，此时取除数量从2变为1。
	if not g:IsExists(aux.NOT(Card.IsRace),1,nil,RACE_REPTILE+RACE_DINOSAUR) then
		ct=1
	end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	c:RemoveOverlayCard(tp,ct,2,REASON_COST)
end
-- ②效果的目标选择及连锁信息设置：从对方场上选择1张表侧表示且能被无效化的卡作为对象，并登记本连锁将进行的无效化处理。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时校验已选对象是否合法：该卡必须是对方场上表侧表示，且满足可被无效化条件。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动时检查：对方场上是否存在至少1张表侧表示且可被无效化的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家发送选择提示，显示‘请选择要无效的卡’的文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上（LOCATION_ONFIELD）选择1张满足条件的表侧表示卡作为本效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本连锁的操作信息：该效果将无效1张卡（CATEGORY_DISABLE），供相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- ②效果处理：取得对象卡，若对象卡仍与效果相关、表侧表示且可被无效化，则使与该卡有关的连锁无效，并给对象卡赋予‘无效’和‘效果无效’状态直到回合结束；若对象是陷阱怪兽，额外无效其陷阱怪兽状态。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第1张对象卡，即之前选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使与对象卡相关的连锁也一并无效化，并在变里侧等重置事件后失效。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local c=e:GetHandler()
		-- 给对象卡施加EFFECT_DISABLE，即让该卡作为卡的效果无效化，持续到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 给对象卡施加EFFECT_DISABLE_EFFECT，即无效该卡所发动的效果，持续到回合结束。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 若对象卡是陷阱怪兽，额外赋予EFFECT_DISABLE_TRAPMONSTER，使其作为陷阱怪兽的卡效果也无效率直到回合结束，以完整实现‘那张卡的效果直到回合结束时无效’。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
