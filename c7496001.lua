--スプリガンズ・ブーティー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的超量怪兽因效果从场上离开的场合，以对方场上1只效果怪兽为对象才能发动。这个回合，那只效果怪兽不能把场上发动的效果发动。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己的卡组·墓地把1张「大沙海 黄金戈尔工达」发动。
function c7496001.initial_effect(c)
	-- 在卡片上注册其关联的卡片密码「大沙海 黄金戈尔工达」
	aux.AddCodeList(c,60884672)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示的超量怪兽因效果从场上离开的场合，以对方场上1只效果怪兽为对象才能发动。这个回合，那只效果怪兽不能把场上发动的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7496001,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,7496001)
	e2:SetCondition(c7496001.actcon)
	e2:SetTarget(c7496001.actg)
	e2:SetOperation(c7496001.actop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己的卡组·墓地把1张「大沙海 黄金戈尔工达」发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7496001,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,7496002)
	e3:SetCost(c7496001.afcost)
	e3:SetTarget(c7496001.aftg)
	e3:SetOperation(c7496001.afop)
	c:RegisterEffect(e3)
end
-- 过滤离开场地的卡是否为自己场上表侧表示的超量怪兽且因效果离场
function c7496001.actfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetPreviousTypeOnField()&TYPE_XYZ~=0
end
-- 效果①的发动条件：检查是否有满足条件的超量怪兽因效果离场
function c7496001.actcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7496001.actfilter,1,nil,tp)
end
-- 过滤对方场上表侧表示的效果怪兽
function c7496001.cfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果①的靶向/对象选择阶段
function c7496001.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c7496001.cfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c7496001.cfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送系统提示：请选择要变成不能发动效果的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(7496001,2))  --"请选择要变成不能发动效果的怪兽"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果对象
	Duel.SelectTarget(tp,c7496001.cfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理：使作为对象的效果怪兽在这个回合不能把场上发动的效果发动
function c7496001.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- ①：这个回合，那只效果怪兽不能把场上发动的效果发动。②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己的卡组·墓地把1张「大沙海 黄金戈尔工达」发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 效果②的发动代价（Cost）：将魔法与陷阱区域表侧表示的这张卡送去墓地
function c7496001.afcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤卡组或墓地中可以发动的「大沙海 黄金戈尔工达」
function c7496001.affilter(c,tp)
	return c:IsCode(60884672) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果②的靶向/目标检查阶段
function c7496001.aftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在可以发动的「大沙海 黄金戈尔工达」
	if chk==0 then return Duel.IsExistingMatchingCard(c7496001.affilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) end
end
-- 效果②的效果处理：从卡组或墓地将1张「大沙海 黄金戈尔工达」在场上发动
function c7496001.afop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示：请选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组或墓地选择1张「大沙海 黄金戈尔工达」（受王家之谷影响）
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c7496001.affilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local field=tc:IsType(TYPE_FIELD)
		if field then
			-- 获取自己场地区域已存在的卡片
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				-- 根据规则将原本存在的场地魔法卡送去墓地
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使后续的移动到场上不与送去墓地同时处理
				Duel.BreakEffect()
			end
			-- 将选择的场地魔法卡表侧表示移动到自己的场地区域
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		else
			-- 将选择的非场地魔法卡表侧表示移动到自己的魔法与陷阱区域
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		if field then
			-- 触发场地魔法卡发动的相关事件时点
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
