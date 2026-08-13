--ARG☆S－HomeStadium
-- 效果：
-- ①：1回合1次，支付1000基本分才能发动。自己的墓地·除外状态的1张「阿尔戈☆群星」卡加入手卡。
-- ②：每次从魔法与陷阱区域往自己场上有永续陷阱卡特殊召唤，给与对方500伤害。
-- ③：自己的「阿尔戈☆群星」怪兽除外中的状态，自己的永续陷阱卡在怪兽区域把效果发动的场合，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化函数：为这张场地魔法卡注册“允许发动”的空效果，并依次注册①回收、②伤害、③无效化这三个效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付1000基本分才能发动。自己的墓地·除外状态的1张「阿尔戈☆群星」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：每次从魔法与陷阱区域往自己场上有永续陷阱卡特殊召唤，给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- ③：自己的「阿尔戈☆群星」怪兽除外中的状态，自己的永续陷阱卡在怪兽区域把效果发动的场合，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果直到回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"无效"
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- ①的发动代价函数：检查玩家能否支付1000基本分，并在发动时实际支付。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认玩家能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 检索过滤器：筛选表侧表示、属于「阿尔戈☆群星」字段且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1c1) and c:IsAbleToHand()
end
-- ①的发动目标判定：检查自己墓地·除外区是否存在1张符合条件的「阿尔戈☆群星」卡，并设置将卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性：自己墓地·除外区存在至少1张满足条件的「阿尔戈☆群星」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：效果处理时将1张卡从墓地·除外区加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①的效果处理：从自己墓地·除外区选择1张不受王家长眠之谷影响的「阿尔戈☆群星」卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地·除外区选择1张满足条件的「阿尔戈☆群星」卡（排除王家长眠之谷适用中的卡）作为加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果原因加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 伤害触发事件的过滤条件：特殊召唤成功的卡是永续陷阱卡、从魔法与陷阱区域特殊召唤且控制者为自己。
function s.cfilter(c,tp)
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsControler(tp)
end
-- 伤害效果的发动条件：本次特殊召唤的怪兽中存在从魔法与陷阱区域特殊召唤到自己场上的永续陷阱卡。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②的效果处理：给与对方玩家500点伤害，并展示本卡动画。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示本卡卡图，作为不入连锁的效果处理提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 以效果原因给与对方玩家500点伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
-- 用于③的过滤器：筛选表侧表示、属于「阿尔戈☆群星」字段的怪兽卡。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1c1)
end
-- ③的发动条件：发动中的效果属于永续陷阱卡且在怪兽区域发动，同时自己除外区存在表侧表示的「阿尔戈☆群星」怪兽，且该效果由自己发动。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS)	and re:GetActivateLocation()==LOCATION_MZONE
		-- 补充条件：自己除外区存在表侧表示的「阿尔戈☆群星」怪兽，且发动该效果的是自己。
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_REMOVED,0,1,nil) and rp==tp
end
-- ③的发动目标：以对方场上1张表侧表示且可被无效化的卡为对象，并设置无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象合法性检查：确认对象为对方场上表侧表示且可被无效化的卡。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动合法性：对方场上有1张可被无效化且可以成为对象的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择1张表侧表示且可被无效化的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将无效对象卡的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ③的效果处理：若对象卡仍为表侧表示且与本效果有关，则使其效果无效，并无效与其相关的连锁；若对象是陷阱怪兽，则再追加使其陷阱怪兽化效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得该效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与该对象卡相关的连锁全部无效，持续到回合结束。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
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
