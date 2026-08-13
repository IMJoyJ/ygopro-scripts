--真竜魔王マスターP
-- 效果：
-- 这张卡通常召唤的场合，必须把自己场上3只怪兽解放作召唤，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡是已上级召唤的场合，对方把手卡·场上的怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。下次的对方主要阶段跳过。
local s,id,o=GetID()
-- 注册该卡全部效果：e0允许将己方场上的永续魔法·永续陷阱卡代替怪兽作为上级召唤祭品；e1规定必须解放3只怪兽进行上级召唤；e2禁止里侧表示通常召唤；e3为①效果的无效并破坏；e4为②效果的跳过对方下次主要阶段。
function s.initial_effect(c)
	-- 可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_SZONE,0)
	-- 限定可代替解放的额外祭品必须是永续魔法·永续陷阱卡。
	e0:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e0:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e0)
	-- 必须把自己场上3只怪兽解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ttcon)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(s.setcon)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡是已上级召唤的场合，对方把手卡·场上的怪兽的效果发动时才能发动。那个发动无效并破坏。
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
-- 过滤函数：用于筛选可代替解放的永续魔法·永续陷阱卡，并要求该卡可供召唤解放。
function s.otfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsReleasable(REASON_SUMMON)
end
-- 上级召唤规则条件：查询能否召唤时返回true；实际召唤时要求至少解放3只，且场上存在足够的祭品。
function s.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断本次通常召唤的祭品需求为3只，且当前存在至少3只可供解放的怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 上级召唤规则操作：选择3只祭品，设定为召唤素材并解放，完成上级召唤所需的解放处理。
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 由召唤玩家从场上选择3只怪兽作为本次上级召唤的解放祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的3只怪兽作为召唤素材解放。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- SET规则限制条件：实际召唤时一律返回false，使这张卡不能里侧表示通常召唤。
function s.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- ①效果发动条件：对方从手卡或场上发动怪兽效果，且该连锁可被无效，同时这张卡处于上级召唤状态。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方发动的效果所在位置，用于判断是否为手卡或场上的怪兽效果。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0
		-- 确认对方发动的是怪兽效果，且当前连锁能够被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- ①效果的目标与操作信息设置：确定要无效并破坏的对象为对方发动的怪兽效果所对应的卡。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本连锁包含‘无效发动’操作，目标为对方发动的连锁（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 当对应怪兽卡可破坏且仍与连锁关联时，追加登记‘破坏’操作。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果处理：若对方发动被无效，且对应怪兽卡仍存在，则将其破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方连锁的发动，并检查那张卡是否仍与连锁关联以便破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将发动被无效的对方怪兽卡以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡以上级召唤状态被战斗或对方的效果破坏，且破坏前在自己场上。
function s.tpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end

-- 用于实现‘下次’判定的条件函数：当前回合数不等于记录值时才满足。
function s.turncon(e)
	-- 当回合数发生变化时条件成立，确保阶段跳过效果在下一回合才开始适用。
	return Duel.GetTurnCount()~=e:GetLabel()
end

-- 创建一个跳过对方主要阶段的场地效果：可跳过主阶段1或主阶段2；next_turn为真则延迟到下一回合，否则本回合生效。
function s.schedule_skip(c,tp,code,next_turn)
	local phase=PHASE_MAIN1
	if code==EFFECT_SKIP_M2 then
		phase=PHASE_MAIN2
	end
	-- 下次的对方主要阶段跳过。
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	e:SetCode(code)
	e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e:SetTargetRange(0,1)
	if next_turn then
		-- 记录当前回合数作为标签，供‘下一次对方回合’判断使用。
		e:SetLabel(Duel.GetTurnCount())
		e:SetCondition(s.turncon)
		e:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e:SetReset(RESET_PHASE+phase+RESET_OPPO_TURN,1)
	end
	-- 将构建好的跳过主要阶段效果注册到游戏中，使其对对方生效。
	Duel.RegisterEffect(e,tp)
	return e
end

-- ②效果处理：根据发动时的回合与阶段，选择跳过对方下一次主要阶段（本次M2或下次M1）。
function s.tpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=1-tp
	-- 获取当前阶段，用于决定跳过M1还是M2。
	local ph=Duel.GetCurrentPhase()
	-- 获取当前回合玩家，判断当前是谁的回合。
	local turn_player=Duel.GetTurnPlayer()

	if turn_player==tp then
		s.schedule_skip(c,tp,EFFECT_SKIP_M1,true)
		return
	end

	-- 若当前为战斗阶段，说明对方本次主要阶段1已过，直接跳过即将到来的主要阶段2。
	if Duel.IsBattlePhase() then
		s.schedule_skip(c,tp,EFFECT_SKIP_M2,false)
		return
	end

	if ph==PHASE_MAIN1 then
		local skip_m1=s.schedule_skip(c,tp,EFFECT_SKIP_M1,true)

		-- 下次的对方主要阶段跳过。
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
		-- 将战斗阶段结束时触发的事件效果注册给对方，用于在战斗阶段结束后把临时的M1跳过替换为跳过M2。
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
