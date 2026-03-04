--真竜魔王マスターP
-- 效果：
-- 这张卡通常召唤的场合，必须把自己场上3只怪兽解放作召唤，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡是已上级召唤的场合，对方把手卡·场上的怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。下次的对方主要阶段跳过。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把自己场上3只怪兽解放作召唤，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。这个卡名的①②的效果1回合各能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_SZONE,0)
	-- 设置祭品为场上的永续魔法·永续陷阱卡
	e0:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e0:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e0)
	-- 上级召唤的这张卡才能通常召唤，且必须解放3只怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡不能通常放置
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(s.setcon)
	c:RegisterEffect(e2)
	-- ①：这张卡是已上级召唤的场合，对方把手卡·场上的怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ②：上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。下次的对方主要阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.tpcon)
	e4:SetOperation(s.tpop)
	c:RegisterEffect(e4)
end
-- 过滤可用于解放的永续魔法·永续陷阱卡
function s.otfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsReleasable(REASON_SUMMON)
end
-- 判断是否满足通常召唤条件
function s.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查场上是否存在3个祭品
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 执行通常召唤操作
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3个祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选中的祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断是否满足通常放置条件
function s.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 判断是否满足效果发动条件
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0
		-- 检查连锁是否为怪兽效果且可无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 设置效果发动目标
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果操作
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并破坏对象卡
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏对象卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断是否满足跳过对方主要阶段条件
function s.tpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end

-- 判断是否满足跳过阶段条件
function s.turncon(e)
	-- 判断回合是否已改变
	return Duel.GetTurnCount()~=e:GetLabel()
end

-- 设置跳过阶段效果
function s.schedule_skip(c,tp,code,next_turn)
	local phase=PHASE_MAIN1
	if code==EFFECT_SKIP_M2 then
		phase=PHASE_MAIN2
	end
	-- 创建并注册跳过阶段效果
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(code)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e:SetTargetRange(0,1)
	if next_turn then
		-- 设置跳过阶段效果的标签为当前回合数
		e:SetLabel(Duel.GetTurnCount())
		e:SetCondition(s.turncon)
		e:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e:SetReset(RESET_PHASE+phase+RESET_OPPO_TURN,1)
	end
	-- 将跳过阶段效果注册给玩家
	Duel.RegisterEffect(e,tp)
	return e
end

-- 处理跳过对方主要阶段效果
function s.tpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=1-tp
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前回合玩家
	local turn_player=Duel.GetTurnPlayer()

	if turn_player==tp then
		s.schedule_skip(c,tp,EFFECT_SKIP_M1,true)
		return
	end

	-- 判断是否处于战斗阶段
	if Duel.IsBattlePhase() then
		s.schedule_skip(c,tp,EFFECT_SKIP_M2,false)
		return
	end

	if ph==PHASE_MAIN1 then
		local skip_m1=s.schedule_skip(c,tp,EFFECT_SKIP_M1,true)

		-- 设置战斗阶段后的跳过效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetCountLimit(1)
		e2:SetLabelObject(skip_m1)
		e2:SetOperation(function(ee,tp2,eg2,ep2,ev2,re2,rp2)
			ee:GetLabelObject():Reset()
			s.schedule_skip(c,tp,EFFECT_SKIP_M2,false)
			ee:Reset()
		end)
		e2:SetReset(RESET_PHASE+PHASE_END,1)
		-- 将战斗阶段后的跳过效果注册给对方玩家
		Duel.RegisterEffect(e2,op)
		return
	end
	if ph>=PHASE_MAIN2 then
		s.schedule_skip(c,tp,EFFECT_SKIP_M1,true)
		return
	end
	if ph<PHASE_MAIN1 then
		s.schedule_skip(c,tp,EFFECT_SKIP_M1,false)
		return
	end
	assert(false)
end
