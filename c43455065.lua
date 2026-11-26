--魔力の泉
-- 效果：
-- 「魔力之泉」在1回合只能发动1张。
-- ①：自己从卡组抽出对方场上的表侧表示的魔法·陷阱卡的数量。那之后，从自己手卡选自己场上的表侧表示的魔法·陷阱卡数量的卡丢弃。这张卡的发动后，直到下次的对方回合的结束时，对方场上的魔法·陷阱卡不会被破坏，发动和效果不会被无效化。
function c43455065.initial_effect(c)
	-- 「魔力之泉」在1回合只能发动1张。①：自己从卡组抽出对方场上的表侧表示的魔法·陷阱卡的数量。那之后，从自己手卡选自己场上的表侧表示的魔法·陷阱卡数量的卡丢弃。这张卡的发动后，直到下次的对方回合的结束时，对方场上的魔法·陷阱卡不会被破坏，发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,43455065+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43455065.target)
	e1:SetOperation(c43455065.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的魔法卡或陷阱卡
function c43455065.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动前确认对方场上存在至少1张表侧魔陷且己方可抽对应数量，并设置目标玩家、抽卡数量及操作信息
function c43455065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方场上表侧表示的魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c43455065.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 发动前确认对方场上表侧魔陷数量大于0且己方可以抽对应张数的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的目标玩家为己方
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为统计出的抽卡数量ct
	Duel.SetTargetParam(ct)
	-- 登记己方从卡组抽ct张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：抽取对方场上表侧魔陷数量的卡并丢弃己方场上表侧魔陷数量的手卡，随后若此卡是作为卡片发动，则为对方场上魔陷注册至下次对方回合结束的防破坏与防无效效果
function c43455065.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家p
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新统计对方场上表侧表示的魔法·陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c43455065.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 让目标玩家效果抽ct张卡，若成功抽卡则继续处理丢弃手卡
	if Duel.Draw(p,ct,REASON_EFFECT)~=0 then
		-- 统计己方场上表侧表示的魔法·陷阱卡数量
		ct=Duel.GetMatchingGroupCount(c43455065.filter,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			-- 插入效果处理间断，使抽卡与后续丢弃手卡视为不同时处理
			Duel.BreakEffect()
			-- 让己方从手卡选择ct张卡以效果丢弃
			Duel.DiscardHand(tp,nil,ct,ct,REASON_EFFECT+REASON_DISCARD)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local rct=1
	-- 若当前为对方回合，则将重置回合计数设为2，以覆盖至下一次对方回合结束时
	if Duel.GetTurnPlayer()~=tp then rct=2 end
	local c=e:GetHandler()
	-- 这张卡的发动后，直到下次的对方回合的结束时，对方场上的魔法·陷阱卡不会被破坏，
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(c43455065.indtg)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 注册使对方场上魔法·陷阱卡不会被效果破坏的全局场地效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	-- 注册使对方怪兽区当作魔法·陷阱卡使用的卡不会被战斗破坏的全局场地效果
	Duel.RegisterEffect(e2,tp)
	-- 发动和效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetValue(c43455065.efilter)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 注册使对方场上魔法·陷阱卡的发动不会被无效化的全局场地效果
	Duel.RegisterEffect(e2,tp)
	-- 发动和效果不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetValue(c43455065.efilter)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 注册使对方场上魔法·陷阱卡发动后的效果不会被无效化的全局场地效果
	Duel.RegisterEffect(e3,tp)
	-- 这张卡的发动后，直到下次的对方回合的结束时，对方场上的魔法·陷阱卡不会被破坏，发动和效果不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISABLE)
	e4:SetTargetRange(0,LOCATION_ONFIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTarget(c43455065.indtg)
	e4:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 注册使对方场上魔法·陷阱卡不会被效果无效化的全局场地效果
	Duel.RegisterEffect(e4,tp)
end
-- 效果适用对象过滤函数：匹配所有属于魔法或陷阱类型的卡片
function c43455065.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 连锁保护校验函数：判断指定连锁是否由对方在场上发动的魔法·陷阱卡触发
function c43455065.efilter(e,ct)
	-- 获取指定连锁ct的触发效果、发动玩家以及发动时所在位置
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return tp~=e:GetHandlerPlayer() and tc:IsType(TYPE_SPELL+TYPE_TRAP) and loc&LOCATION_ONFIELD~=0
end
