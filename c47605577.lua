--レイズ・ムーンの朔 スクイーズ
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，从以下效果选择1个才能发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- 发动的这张卡的效果的决斗中，自己不能用抽卡以外的方法从卡组把卡加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		-- 注册全局监听效果：记录从卡组把卡加入手卡的行为
		Duel.RegisterEffect(ge1,0)
	end
end
-- 监听处理：若非抽卡将卡组的卡加入手卡，则为玩家注册标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历加入手卡的卡片组
	for tc in aux.Next(eg) do
		if not tc:IsReason(REASON_DRAW) and tc:IsPreviousLocation(LOCATION_DECK) then
			-- 为将卡加入手卡的玩家注册标记（本决斗进行过检索）
			Duel.RegisterFlagEffect(rp,id,0,0,1)
		end
	end
end
-- 效果发动代价：丢弃自身，且该决斗不能再进行检索
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认本决斗中自己未进行过检索
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and c:IsDiscardable() end
	-- 把这张卡从手卡丢弃去墓地作为代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	-- 发动的这张卡的效果的决斗中，自己不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	-- 限制范围：卡组的卡不能加入手卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	-- 为发动玩家注册决斗誓约效果：不能通过抽卡以外的方法从卡组将卡加入手卡
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动选项检查与分支选择
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查选项1（对方检索时抽卡）本回合是否尚未使用
	local b1=(not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	-- 确认自己能够抽1张卡
	local b2=Duel.IsPlayerCanDraw(tp,1)
		-- 检查选项2（抽1张卡）本回合是否尚未使用
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o*2)==0)
	if chk==0 then return b1 or b2 end
	-- 让玩家在可用选项中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			-- 注册选项1本回合已使用的标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			-- 注册选项2本回合已使用的标记
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置抽卡目标玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 设置抽卡数量为1
		Duel.SetTargetParam(1)
		-- 设置操作信息：自己抽1张
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理：根据选择的分支执行对应效果
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- ●这个回合中，每次抽卡以外的方法有卡加入对方手卡，自己抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_TO_HAND)
		e1:SetCondition(s.drcon1)
		e1:SetOperation(s.drop1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册非连锁中对方将卡加入手卡时的抽卡效果
		Duel.RegisterEffect(e1,tp)
		-- ●这个回合中，每次抽卡以外的方法有卡加入对方手卡，自己抽1张。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_TO_HAND)
		e2:SetCondition(s.regcon)
		e2:SetOperation(s.regop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册连锁处理中对方将卡加入手卡的标记效果
		Duel.RegisterEffect(e2,tp)
		-- ●这个回合中，每次抽卡以外的方法有卡加入对方手卡，自己抽1张。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_CHAIN_SOLVED)
		e3:SetCondition(s.drcon2)
		e3:SetOperation(s.drop2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册连锁处理完毕后根据加入手卡次数抽卡的效果
		Duel.RegisterEffect(e3,tp)
		-- 这个效果的发动后，直到下个回合的结束时自己不是7阶超量怪兽不能从额外卡组特殊召唤。
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,4))
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e4:SetTargetRange(1,0)
		e4:SetTarget(s.splimit)
		e4:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册额外卡组特殊召唤限制：直到下个回合结束时只能特殊召唤7阶超量怪兽
		Duel.RegisterEffect(e4,tp)
		-- ●这个回合中，每次抽卡以外的方法有卡加入对方手卡，自己抽1张。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e5:SetCode(EVENT_CHAINING)
		e5:SetCondition(s.chaindrawcon)
		e5:SetOperation(s.procdraw)
		e5:SetReset(RESET_PHASE+PHASE_END)
		-- 注册连锁开始时补抽卡片的效果
		Duel.RegisterEffect(e5,tp)
		-- ●自己抽1张。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_DELAY)
		e6:SetCode(EVENT_SPSUMMON_SUCCESS)
		e6:SetCondition(s.succon)
		e6:SetOperation(s.procdraw)
		e6:SetReset(RESET_PHASE+PHASE_END)
		-- 注册特殊召唤成功时补抽卡片的效果
		Duel.RegisterEffect(e6,tp)
		local e7=e6:Clone()
		e7:SetCode(EVENT_SUMMON_SUCCESS)
		-- 注册通常召唤成功时补抽卡片的效果
		Duel.RegisterEffect(e7,tp)
	elseif e:GetLabel()==2 then
		-- 获取抽卡目标玩家与数量
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行抽卡：自己抽1张
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
-- 过滤对方非抽卡加入手卡的卡片
function s.cfilter(c,tp)
	return c:IsControler(1-tp) and not c:IsReason(REASON_DRAW)
end
-- 过滤因特殊召唤手续送墓/除外等导致加入手卡的情况
function s.procfilter(c,tp)
	return s.cfilter(c,tp) and c:IsReason(REASON_SPSUMMON)
end
-- 非连锁处理中对方加手卡触发条件
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查存在对方非抽卡加入手卡的卡且当前没有连锁在处理
	return eg:IsExists(s.cfilter,1,nil,tp) and not Duel.IsChainSolving()
end
-- 非连锁处理中抽卡处理
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.procfilter,1,nil,tp) then
		-- 若属于特殊召唤手续导致加入手卡，则注册延迟抽卡标记
		Duel.RegisterFlagEffect(tp,id+o*4,RESET_PHASE+PHASE_END,0,1)
		return
	end
	-- 向双方显示卡片发动效果的动画
	Duel.Hint(HINT_CARD,0,id)
	-- 自己抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 连锁开始时补抽卡的条件
function s.chaindrawcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为1且存在未处理的延迟抽卡标记
	return Duel.GetCurrentChain()==1 and Duel.GetFlagEffect(tp,id+o*4)>0
end
-- 召唤·特殊召唤成功时补抽卡的条件
function s.succon(e,tp,eg,ep,ev,re,r,rp)
	-- 存在未处理的延迟抽卡标记且当前没有连锁在处理
	return Duel.GetFlagEffect(tp,id+o*4)>0 and not Duel.IsChainSolving()
end
-- 补抽卡片的效果处理
function s.procdraw(e,tp,eg,ep,ev,re,r,rp)
	-- 获取延迟抽卡的累计次数
	local ct=Duel.GetFlagEffect(tp,id+o*4)
	-- 重置延迟抽卡标记
	Duel.ResetFlagEffect(tp,id+o*4)
	-- 向双方显示卡片发动效果的动画
	Duel.Hint(HINT_CARD,0,id)
	-- 自己补抽对应数量的卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
-- 连锁处理中对方加手卡的标记注册条件
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查存在对方非抽卡加入手卡的卡且当前正在处理连锁
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsChainSolving()
end
-- 为该连锁注册抽卡次数标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册连锁结束时抽卡的标记（每次加手卡增加1次）
	Duel.RegisterFlagEffect(tp,id+o*3,RESET_CHAIN,0,1)
end
-- 连锁处理完毕时抽卡的条件
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该连锁中是否注册了抽卡标记
	return Duel.GetFlagEffect(tp,id+o*3)>0
end
-- 连锁处理完毕后的抽卡处理
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该连锁中累计的抽卡次数
	local ct=Duel.GetFlagEffect(tp,id+o*3)
	-- 重置该连锁的抽卡标记
	Duel.ResetFlagEffect(tp,id+o*3)
	-- 向双方显示卡片发动效果的动画
	Duel.Hint(HINT_CARD,0,id)
	-- 自己抽对应数量的卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
-- 过滤额外卡组非7阶超量怪兽（限制特殊召唤）
function s.splimit(e,c)
	return not (c:IsRank(7) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
