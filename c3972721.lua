--グリード・グラード
-- 效果：
-- 自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
function c3972721.initial_effect(c)
	-- 自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(c3972721.condition)
	e1:SetTarget(c3972721.target)
	e1:SetOperation(c3972721.activate)
	c:RegisterEffect(e1)
	if not c3972721.global_check then
		c3972721.global_check=true
		-- 自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c3972721.checkop)
		-- 将全局持续监测效果ge1注册到玩家0，使全场怪兽被破坏事件都能触发checkop，用于记录满足发动条件的回合。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历被破坏的怪兽组，筛选出满足条件的同调怪兽：曾被表侧表示存在于主要怪兽区、因战斗破坏时表侧表示或因效果破坏前是表侧表示，且原控制者与破坏原因玩家不同，分别置位p1/p2标记。
function c3972721.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsType(TYPE_SYNCHRO) and tc:IsPreviousLocation(LOCATION_MZONE)
			and ((tc:IsReason(REASON_BATTLE) and bit.band(tc:GetBattlePosition(),POS_FACEUP)~=0)
			or (not tc:IsReason(REASON_BATTLE) and tc:IsPreviousPosition(POS_FACEUP)))
			and tc:GetPreviousControler()~=tc:GetReasonPlayer() then
			if tc:GetReasonPlayer()==0 then p1=true else p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若玩家0满足条件，则给玩家0注册编号3972721的回合标记，持续到结束阶段，作为其发动条件依据。
	if p1 then Duel.RegisterFlagEffect(0,3972721,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1满足条件，则给玩家1注册编号3972721的回合标记，持续到结束阶段，作为其发动条件依据。
	if p2 then Duel.RegisterFlagEffect(1,3972721,RESET_PHASE+PHASE_END,0,1) end
end
-- 发动条件判定函数：检查发动玩家tp是否持有本回合满足过破坏条件的标记，以此控制只能在该回合发动。
function c3972721.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家tp是否存在编号3972721的标记（非0表示存在），即本回合已满足破坏对方表侧同调怪兽的条件。
	return Duel.GetFlagEffect(tp,3972721)~=0
end
-- 发动时的目标处理函数：在合法时登记抽卡对象玩家为tp、抽卡数为2，并设置操作信息。
function c3972721.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测：检查玩家tp能否抽2张卡，若不能则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁处理的对象玩家设置为tp，表示由tp执行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为2，表示抽卡数量。
	Duel.SetTargetParam(2)
	-- 设置操作信息：效果分类为抽卡（CATEGORY_DRAW），处理时由tp玩家抽2张，目标卡不在此刻指定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从连锁信息取得对象玩家和抽卡数量，让该玩家抽对应数量的卡。
function c3972721.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家和参数，分别存入p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
