--ポップルアップ
-- 效果：
-- 「弹出式翻页」在1回合只能发动1张。
-- ①：对方的场地区域有卡存在，自己的场地区域没有卡存在的场合才能发动。从卡组把1张场地魔法卡发动。
function c15248873.initial_effect(c)
	-- 「弹出式翻页」在1回合只能发动1张。①：对方的场地区域有卡存在，自己的场地区域没有卡存在的场合才能发动。从卡组把1张场地魔法卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15248873+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15248873.condition)
	e1:SetTarget(c15248873.target)
	e1:SetOperation(c15248873.operation)
	c:RegisterEffect(e1)
end
-- 该函数作为效果发动条件判定：必须满足自己场地区没有卡，且对方场地区有卡，此卡才能发动。
function c15248873.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 查询己方场地区第0格不存在卡，且对方场地区第0格存在卡，以此实现“自己的场地区域没有卡存在，对方的场地区域有卡存在”的发动条件。
	return Duel.GetFieldCard(tp,LOCATION_FZONE,0)==nil and Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)~=nil
end
-- 过滤卡组中的卡：必须为场地魔法卡，并且其“卡的发动”效果在当前玩家tp处可以发动（不检查发动位置和对象要求），以确保选出的卡能实际发动。
function c15248873.filter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果发动时的目标判断与准备：验证卡组中是否存在可发动的场地魔法卡，并记录当前阶段是否尚无操作，供处理时使用。
function c15248873.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性检查：若己方卡组中不存在至少1张满足filter条件的场地魔法卡，则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c15248873.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 检查当前阶段是否还没有任何操作（即处于阶段刚开始的时点）；若无操作则将效果标签设为1，否则设为0，该标记用于后续处理时的流程控制。
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
-- 效果处理：从卡组选择1张场地魔法卡并发动；若己方场地区已有场地魔法卡，则先按规则将其送去墓地并错开时点，再将选出的卡放到自己的场地区域发动。
function c15248873.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家tp显示选择提示，提示文字为“请选择一张场地魔法卡”，用于卡组选卡时的UI指引。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(15248873,0))  --"请选择一张场地魔法卡"
	-- 若此前记录到当前处于阶段刚开始且无操作的状态，则给己方玩家注册一个连锁结束即重置的标记效果，用于该流程中的临时规则控制；该标记会在选择卡后立刻被清除。
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	-- 从己方卡组中选出1张满足filter条件的场地魔法卡（不取对象，处理时选择），并取得选中的那张卡。
	local tc=Duel.SelectMatchingCard(tp,c15248873.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 立即清除刚刚注册的临时标记效果，使该标记仅在选卡过程中生效，选完后即失效。
	Duel.ResetFlagEffect(tp,15248873)
	if tc then
		-- 获取己方场地区第0格当前的卡，用于检查是否已有场地魔法卡占据场地区。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将已有的场地魔法卡按游戏规则送入墓地（非效果破坏或效果送墓），因为场地魔法区域只能存在1张场地魔法卡。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，将“旧场地送入墓地”和“新场地魔法卡发动”分成不同的处理时点，避免时点被错误合并。
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡移动到己方场地区，以表侧表示放置并立即适用其效果；此操作相当于将该卡放到场上，但尚未完成发动宣告。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 以该场地魔法卡的发动效果(te)为来源，在当前连锁中触发其发动时点，正式完成“从卡组把1张场地魔法卡发动”的发动动作。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
