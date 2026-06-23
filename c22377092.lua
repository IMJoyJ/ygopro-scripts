--トラップホリック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组把「沉迷陷溺」以外的1张通常陷阱卡在自己场上盖放。这个效果盖放的卡只要自己墓地有陷阱卡3张以上存在，在盖放的回合也能发动。
local s,id,o=GetID()
-- 创建效果，设置发动条件为自由连锁，限制每回合只能发动一次，需要选择对象卡，目标为己方场上的魔法·陷阱卡，效果分类为破坏和盖放
function s.initial_effect(c)
	-- ①：以自己场上1张魔法·陷阱卡为对象才能发动。那张卡破坏，从卡组把「沉迷陷溺」以外的1张通常陷阱卡在自己场上盖放。这个效果盖放的卡只要自己墓地有陷阱卡3张以上存在，在盖放的回合也能发动。
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
-- 过滤函数，用于判断是否满足破坏条件的魔法·陷阱卡
function s.desfilter(c,tp,ft)
	-- 满足类型为魔法·陷阱卡且场上空位足够
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetSZoneCount(tp,c)>ft
end
-- 过滤函数，用于判断是否满足盖放条件的通常陷阱卡
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsCode(id) and c:IsSSetable(true)
end
-- 判断目标是否满足条件，必须在场上、控制者为玩家、类型为魔法·陷阱卡且不为自身
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp)
			and chkc:IsType(TYPE_SPELL+TYPE_TRAP) and chkc~=e:GetHandler() end
	local ft=0
	if chk==0 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=1 end
		-- 检查是否存在满足破坏条件的目标卡
		return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),tp,ft)
			-- 检查卡组中是否存在满足盖放条件的卡
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp,ft)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 发动效果，先破坏目标卡，再从卡组选择一张通常陷阱卡盖放
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且在场上，且破坏成功
	if tc and tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)>0
		-- 判断场上是否有足够的空位进行盖放
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择一张满足条件的通常陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local sc=g:GetFirst()
		-- 将选中的卡盖放到场上
		if sc and Duel.SSet(tp,sc)~=0 then
			-- 适用「沉迷陷溺」的效果来发动
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
-- 判断墓地是否至少有3张陷阱卡
function s.actcon(e)
	-- 检查墓地中是否存在至少3张陷阱卡
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil,TYPE_TRAP)
end
