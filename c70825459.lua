--トラップトラック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，从卡组把「蛊惑陷迹」以外的1张通常陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
local s,id,o=GetID()
-- 定义卡片初始化效果，注册卡片发动时的效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，从卡组把「蛊惑陷迹」以外的1张通常陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中除「蛊惑陷迹」以外的可盖放的通常陷阱卡。
function s.filter(c)
	return c:GetType()==TYPE_TRAP and not c:IsCode(id) and c:IsSSetable(true)
end
-- 卡片发动时的靶向处理，检查并选择要破坏的怪兽，并设置破坏的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then
		-- 获取自己魔陷区的可用空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 检查自己魔陷区是否有空位，且自己场上是否存在可以作为对象的怪兽。
		return ft>0 and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在满足过滤条件的通常陷阱卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理的核心逻辑，处理怪兽破坏、卡组盖卡、赋予盖卡当回合发动能力以及注册后续的陷阱卡发动限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用此效果，并将其因效果破坏。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 提示玩家选择要盖放的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足过滤条件的通常陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		-- 将选中的通常陷阱卡在自己场上盖放。
		if tc and Duel.SSet(tp,tc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(70825459,0))  --"适用「蛊惑陷迹」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(s.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果，用于在玩家发动陷阱卡时记录发动次数。
		Duel.RegisterEffect(e2,tp)
		-- 这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_CHAIN_NEGATED)
		e3:SetOperation(s.aclimit2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果，用于在玩家发动的陷阱卡被无效时重置发动次数记录。
		Duel.RegisterEffect(e3,tp)
		-- 这张卡的发动后，直到回合结束时自己只能有1张陷阱卡发动。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetCode(EFFECT_CANNOT_ACTIVATE)
		e4:SetTargetRange(1,0)
		e4:SetCondition(s.actcon)
		e4:SetValue(s.aclimit3)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果，在玩家本回合已发动过陷阱卡时，禁止其再次发动陷阱卡。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 监听陷阱卡发动的事件，若自己发动了陷阱卡，则注册一个已发动的标识。
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) then return end
	-- 为玩家注册一个回合结束前有效的标识，表示本回合已发动过1张陷阱卡。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 监听发动被无效的事件，若自己发动的陷阱卡被无效，则清除已发动的标识。
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) then return end
	-- 清除表示已发动过陷阱卡的标识。
	Duel.ResetFlagEffect(tp,id)
end
-- 检查玩家本回合是否已经存在发动过陷阱卡的标识。
function s.actcon(e)
	-- 判断玩家是否已存在发动过陷阱卡的标识。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)~=0
end
-- 限制发动卡片的类型，指定为陷阱卡的发动。
function s.aclimit3(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
