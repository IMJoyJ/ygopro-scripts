--招来の対価
-- 效果：
-- 这张卡发动的回合的结束阶段时，这个回合自己从手卡·场上解放的衍生物以外的怪兽数量的以下效果适用。「招来的对价」在1回合只能发动1张。
-- ●1只：从卡组抽1张卡。
-- ●2只：选自己墓地2只怪兽加入手卡。
-- ●3只以上：选场上表侧表示存在的最多3张卡破坏。
function c26285788.initial_effect(c)
	-- “这张卡发动的回合的结束阶段时，这个回合自己从手卡·场上解放的衍生物以外的怪兽数量的以下效果适用。「招来的对价」在1回合只能发动1张。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26285788+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26285788.target)
	e1:SetOperation(c26285788.activate)
	c:RegisterEffect(e1)
	if not c26285788.global_check then
		c26285788.global_check=true
		-- “这个回合自己从手卡·场上解放的衍生物以外的怪兽数量”
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(c26285788.addcount)
		-- 将记录解放怪兽数量的全局效果ge1注册到环境（玩家0），使全场每次有怪兽被解放时都触发addcount进行计数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历本次解放的怪兽集合eg，每当其中有怪兽且不是衍生物时，就为该怪兽的解放原因玩家p累计一次解放计数（用于统计“从手卡·场上解放的衍生物以外的怪兽数量”）。
function c26285788.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_TOKEN) then
			local p=tc:GetReasonPlayer()
			-- 为玩家p注册1个编号为26285789的标志，结束阶段时重置；该标志数量表示该玩家本回合解放的符合条件的怪兽数量。
			Duel.RegisterFlagEffect(p,26285789,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 发动时的检查：仅在作为魔法·陷阱卡的“发动”时（EFFECT_TYPE_ACTIVATE）且没有其他条件时允许发动，即这张卡只能以通常魔法卡发动的形式发动。
function c26285788.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 这张卡发动成功后，在当前回合的结束阶段注册一个延迟效果e1；该效果在结束阶段时判断条件，条件满足则执行效果处理，并在结束阶段结束时自动重置，1回合最多处理1次。
function c26285788.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- “●1只：从卡组抽1张卡。●2只：选自己墓地2只怪兽加入手卡。●3只以上：选场上表侧表示存在的最多3张卡破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c26285788.effectcon)
	e1:SetOperation(c26285788.effectop)
	-- 将上述结束阶段处理用的延迟效果e1注册给发动玩家tp，使该效果只在这一回合的结束阶段对tp生效。
	Duel.RegisterEffect(e1,tp)
end
-- 该结束阶段效果的发动条件：当前玩家tp本回合确实解放过“衍生物以外的怪兽”（26285789标志数量>0）时才可处理。
function c26285788.effectcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回tp拥有的26285789标志数量是否大于0，以此判断本回合是否解放过符合条件的怪兽。
	return Duel.GetFlagEffect(tp,26285789)>0
end
-- 墓地怪兽的筛选条件：是怪兽且可以加入手卡，用于“选自己墓地2只怪兽加入手卡”这一分支。
function c26285788.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 破坏对象筛选条件：场上表侧表示存在的卡，用于“选场上表侧表示存在的最多3张卡破坏”这一分支。
function c26285788.filter2(c)
	return c:IsFaceup()
end
-- 结束阶段的实际效果处理：根据本回合解放数量ct选择分支；ct=1抽1张卡，ct=2从墓地选2只怪兽加入手卡，ct>=3破坏场上表侧表示的最多3张卡。
function c26285788.effectop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示“招来的对价”的卡片动画/提示，因为结束阶段处理的效果不属于通常连锁，需要手动提示来源。
	Duel.Hint(HINT_CARD,0,26285788)
	-- 读取当前玩家tp本回合解放的“衍生物以外的怪兽”数量（26285789标志的层数），用于决定适用哪个效果。
	local ct=Duel.GetFlagEffect(tp,26285789)
	if ct==1 then
		-- 当前玩家tp以效果原因抽1张卡，对应“●1只：从卡组抽1张卡。”
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif ct==2 then
		-- 检索自己墓地中满足“怪兽且可加入手卡”且不受王家长眠之谷影响的卡，生成可选组，用于后续选择2只加入手卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c26285788.filter1),tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>1 then
			-- 弹出选择提示“请选择要加入手牌的卡”，让玩家从符合条件的选择组中选卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local tg=g:Select(tp,2,2,nil)
			-- 把选中的2只墓地怪兽以效果原因加入其持有者的手卡，对应“●2只：选自己墓地2只怪兽加入手卡。”
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认，保证公开信息。
			Duel.ConfirmCards(1-tp,tg)
		end
	else
		-- 检索场上双方所有表侧表示的卡，生成可选组，用于后续选择最多3张破坏。
		local g=Duel.GetMatchingGroup(c26285788.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 then
			-- 弹出选择提示“请选择要破坏的卡”，让玩家从符合条件的选择组中选卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local tg=g:Select(tp,1,3,nil)
			-- 将选中的最多3张表侧表示卡以效果原因破坏，对应“●3只以上：选场上表侧表示存在的最多3张卡破坏。”
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
