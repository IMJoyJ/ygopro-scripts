--魂縛門
-- 效果：
-- 自己场上盖放的魔法·陷阱卡被效果破坏的回合，自己场上没有怪兽存在的场合才能把这张卡发动。
-- ①：自己·对方的主要阶段，自己墓地有「Z-ONE」存在，只让持有比自己基本分数值低的攻击力的怪兽1只召唤·反转召唤·特殊召唤的场合发动。那只怪兽破坏，自己受到800伤害。那之后，给与对方800伤害。
function c6909330.initial_effect(c)
	-- 自己场上盖放的魔法·陷阱卡被效果破坏的回合，自己场上没有怪兽存在的场合才能把这张卡发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(c6909330.condition)
	c:RegisterEffect(e0)
	-- ①：自己·对方的主要阶段，自己墓地有「Z-ONE」存在，只让持有比自己基本分数值低的攻击力的怪兽1只召唤·反转召唤·特殊召唤的场合发动。那只怪兽破坏，自己受到800伤害。那之后，给与对方800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6909330,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(c6909330.descon)
	e1:SetTarget(c6909330.destg)
	e1:SetOperation(c6909330.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	if not c6909330.global_check then
		c6909330.global_check=true
		-- 自己场上盖放的魔法·陷阱卡被效果破坏的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c6909330.regop)
		-- 注册全局环境下的事件监听效果，用于记录盖放的魔陷被效果破坏的信息
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤出原本在场上盖放且因效果破坏而被送去墓地或除外的魔法·陷阱卡
function c6909330.filter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and c:GetPreviousTypeOnField()&(TYPE_SPELL+TYPE_TRAP)~=0
		and c:IsReason(REASON_EFFECT)
end
-- 在有符合条件的卡被破坏时，为该卡的原本控制者注册一个持续到回合结束的标识效果
function c6909330.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c6909330.filter,nil)
	local tc=g:GetFirst()
	while tc do
		-- 检查该卡的原本控制者在本回合是否还未注册过魔陷被效果破坏的标识
		if Duel.GetFlagEffect(tc:GetPreviousControler(),6909330)==0 then
			-- 为该玩家注册一个持续到回合结束的标识，表示其本回合有盖放的魔陷被效果破坏
			Duel.RegisterFlagEffect(tc:GetPreviousControler(),6909330,RESET_PHASE+PHASE_END,0,1)
		end
		-- 若双方玩家都已经满足了“盖放魔陷被效果破坏”的条件，则提前结束循环
		if Duel.GetFlagEffect(0,6909330)>0 and Duel.GetFlagEffect(1,6909330)>0 then
			break
		end
		tc=g:GetNext()
	end
end
-- 检查发动此卡时，当前回合自己是否有盖放的魔陷被效果破坏，且自己场上没有怪兽存在
function c6909330.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足“本回合自己有盖放的魔陷被效果破坏”且“自己场上没有怪兽存在”的条件
	return Duel.GetFlagEffect(tp,6909330)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 检查是否在双方的主要阶段，且仅有1只攻击力低于自己基本分的怪兽被召唤·反转召唤·特殊召唤，且自己墓地存在「Z-ONE」
function c6909330.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) then return false end
	if eg:GetCount()>1 then return false end
	local tc=eg:GetFirst()
	if not tc then return false end
	e:SetLabelObject(tc)
	-- 检查该怪兽是否在怪兽区域表侧表示存在，且其攻击力低于自己当前的基本分
	return tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and tc:GetAttack()<Duel.GetLP(tp)
		-- 检查自己墓地是否存在卡名为「Z-ONE」的卡
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,62499965)
end
-- 设定被召唤的怪兽为效果处理对象，并注册破坏怪兽和造成伤害的操作信息
function c6909330.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc end
	-- 将该召唤的怪兽设为当前效果的处理对象
	Duel.SetTargetCard(tc)
	-- 设置破坏该怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置给双方玩家造成800点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,800)
end
-- 执行效果处理：破坏目标怪兽并对自己造成800点伤害，若自己基本分仍大于0，则再给对方造成800点伤害
function c6909330.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍适用此效果，若成功将其破坏并对自己造成800点伤害，且自己基本分仍大于0，则继续处理后续效果
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.Damage(tp,800,REASON_EFFECT)~=0 and Duel.GetLP(tp)>0 then
		-- 中断当前效果处理，使后续的伤害处理不与前面的处理同时进行
		Duel.BreakEffect()
		-- 给对方玩家造成800点伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
