--トラップホリック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组把「沉迷陷溺」以外的1张通常陷阱卡在自己场上盖放。这个效果盖放的卡只要自己墓地有陷阱卡3张以上存在，在盖放的回合也能发动。
local s,id,o=GetID()
-- 定义初始效果注册函数：创建并注册「沉迷陷溺」的①效果（一回合一次，取对象破坏自己场上的魔陷并从卡组盖放通常陷阱），设置发动类型、限制、对象筛选与处理流程。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组把「沉迷陷溺」以外的1张通常陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义破坏对象的筛选函数：对象必须是魔法陷阱卡，且以其为对象破坏后，自己场上魔陷区仍至少有ft个空格可用（考虑发动卡自身占位）。
function s.desfilter(c,tp,ft)
	-- 判断条件：该卡是魔法陷阱卡，且破坏后（连同已计算的手牌发动占位）魔陷区仍有足够空格。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetSZoneCount(tp,c)>ft
end
-- 定义卡组盖放卡的筛选函数：必须是通常陷阱卡，卡名不是「沉迷陷溺」，且可以无视魔陷区格子限制进行盖放。
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsCode(id) and c:IsSSetable(true)
end
-- 在连锁处理中检查对象合法性：对象须为场上由自己控制的魔法陷阱卡，且不是发动效果的本卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp)
			and chkc:IsType(TYPE_SPELL+TYPE_TRAP) and chkc~=e:GetHandler() end
	local ft=0
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=1 end
		-- 发动时判定：自己场上是否存在至少1张满足破坏条件且可被选为对象的魔法陷阱卡（排除本卡）。
		return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp,ft)
			-- 发动时判定：卡组中存在至少1张满足盖放条件的通常陷阱卡（卡名不是「沉迷陷溺」）。
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
	-- 向玩家弹出选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1张满足条件的魔法陷阱卡作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp,ft)
	-- 设置本次连锁的操作信息：将要执行1次破坏处理，目标为已选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理函数：取对象，若对象仍相关且在场上则将其破坏；破坏成功且魔陷区有空位时，从卡组选1张通常陷阱盖放，并给该盖放卡赋予‘墓地有3张以上陷阱时可在盖放回合发动’的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的连锁对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与连锁相关、仍在场上，且用效果将其破坏成功。
	if tc and tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)>0
		-- 确认自己魔陷区仍有空格，用于盖放从卡组选出的陷阱卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 向玩家弹出选择提示，要求选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择1张满足条件的通常陷阱卡（卡名不是「沉迷陷溺」）。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local sc=g:GetFirst()
		-- 若成功选择了卡并将其盖放到魔陷区，则继续给该卡附加效果。
		if sc and Duel.SSet(tp,sc)~=0 then
			-- 这个效果盖放的卡只要自己墓地有陷阱卡3张以上存在，在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))  --"适用「沉迷陷溺」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.actcon)
			sc:RegisterEffect(e1)
		end
	end
end
-- 定义附加效果的发动条件：自己墓地存在3张以上陷阱卡。
function s.actcon(e)
	-- 判断该效果的持有者墓地中是否有3张以上陷阱卡。
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil,TYPE_TRAP)
end
