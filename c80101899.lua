--トラップトリック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把「蛊惑谋陷」以外的1张通常陷阱卡除外，那1张同名卡从卡组到自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
function c80101899.initial_effect(c)
	-- ①：从卡组把「蛊惑谋陷」以外的1张通常陷阱卡除外，那1张同名卡从卡组到自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,80101899+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c80101899.target)
	e1:SetOperation(c80101899.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中除「蛊惑谋陷」以外、且卡组中存在同名卡可盖放的通常陷阱卡
function c80101899.rmfilter(c,tp)
	return c:GetType()==TYPE_TRAP and not c:IsCode(80101899) and c:IsAbleToRemove()
		-- 检查卡组中是否存在与被除外卡同名的可盖放卡片
		and Duel.IsExistingMatchingCard(c80101899.setfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
-- 过滤卡组中与指定卡同名且可以盖放的卡片
function c80101899.setfilter(c,code)
	return c:IsCode(code) and c:IsSSetable()
end
-- 效果发动的目标过滤与操作信息设置
function c80101899.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足除外条件的通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80101899.rmfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：除外卡组中的通常陷阱卡，盖放同名卡，并适用后续限制
function c80101899.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1张满足条件的通常陷阱卡
	local g1=Duel.SelectMatchingCard(tp,c80101899.rmfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	-- 若成功将选择的卡片表侧表示除外
	if tc1 and Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_REMOVED) then
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张与除外卡同名的卡片
		local g2=Duel.SelectMatchingCard(tp,c80101899.setfilter,tp,LOCATION_DECK,0,1,1,nil,tc1:GetCode())
		local tc2=g2:GetFirst()
		-- 若成功将同名卡在自己场上盖放
		if tc2 and Duel.SSet(tp,tc2)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(80101899,0))  --"适用「蛊惑谋陷」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(c80101899.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果：在玩家发动陷阱卡时记录发动次数
		Duel.RegisterEffect(e2,tp)
		-- 这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_CHAIN_NEGATED)
		e3:SetOperation(c80101899.aclimit2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果：在玩家发动的陷阱卡发动被无效时，重置发动次数记录
		Duel.RegisterEffect(e3,tp)
		-- 这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetCode(EFFECT_CANNOT_ACTIVATE)
		e4:SetTargetRange(1,0)
		e4:SetCondition(c80101899.actcon)
		e4:SetValue(c80101899.aclimit3)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果：在已发动过1张陷阱卡后，禁止发动新的陷阱卡
		Duel.RegisterEffect(e4,tp)
	end
end
-- 陷阱卡发动时的处理：如果是自己发动的陷阱卡，则注册已发动标记
function c80101899.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) then return end
	-- 给玩家注册已发动1张陷阱卡的全局标记
	Duel.RegisterFlagEffect(tp,80101899,RESET_PHASE+PHASE_END,0,1)
end
-- 陷阱卡发动被无效时的处理：如果是自己发动的陷阱卡被无效，则清除已发动标记
function c80101899.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) then return end
	-- 清除玩家已发动1张陷阱卡的全局标记
	Duel.ResetFlagEffect(tp,80101899)
end
-- 限制发动效果的启用条件：玩家已注册了发动陷阱卡的标记
function c80101899.actcon(e)
	-- 检查玩家是否已存在发动陷阱卡的标记
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),80101899)~=0
end
-- 限制发动的卡片类型：限制陷阱卡的发动
function c80101899.aclimit3(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
