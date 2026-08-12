--フェイバリット・ヒーロー
-- 效果：
-- 5星以上的「英雄」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：自己的场地区域有卡存在的场合，装备怪兽攻击力上升原本守备力数值，对方不能把装备怪兽作为效果的对象。
-- ②：自己·对方的战斗阶段开始时才能发动。从自己的手卡·卡组把1张场地魔法卡发动。
-- ③：装备怪兽的攻击破坏对方怪兽时，把这张卡送去墓地才能发动。那只攻击怪兽只再1次可以继续攻击。
function c11881272.initial_effect(c)
	-- ①：自己的场地区域有卡存在的场合，装备怪兽攻击力上升原本守备力数值，对方不能把装备怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c11881272.target)
	e1:SetOperation(c11881272.operation)
	c:RegisterEffect(e1)
	-- 5星以上的「英雄」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c11881272.eqlimit)
	c:RegisterEffect(e2)
	-- 自己的场地区域有卡存在的场合，装备怪兽攻击力上升原本守备力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c11881272.atkval)
	e3:SetCondition(c11881272.atkcon)
	c:RegisterEffect(e3)
	-- 对方不能把装备怪兽作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 不会成为对方的卡的效果对象的过滤函数的简单写法，用在效果注册里 SetValue
	e4:SetValue(aux.tgoval)
	e4:SetCondition(c11881272.atkcon)
	c:RegisterEffect(e4)
	-- ②：自己·对方的战斗阶段开始时才能发动。从自己的手卡·卡组把1张场地魔法卡发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11881272,0))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,11881272)
	e5:SetTarget(c11881272.acttg)
	e5:SetOperation(c11881272.actop)
	c:RegisterEffect(e5)
	-- ③：装备怪兽的攻击破坏对方怪兽时，把这张卡送去墓地才能发动。那只攻击怪兽只再1次可以继续攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(11881272,1))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DESTROYING)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c11881272.chacon)
	e6:SetCost(c11881272.chacost)
	e6:SetOperation(c11881272.chaop)
	c:RegisterEffect(e6)
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c11881272.eqfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSetCard(0x8)
end
-- 设置选择目标时的处理函数
function c11881272.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11881272.eqfilter(chkc) end
	-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	if chk==0 then return Duel.IsExistingTarget(c11881272.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家player发送提示信息，提示内容为desc
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 让玩家sel_player选择以player来看的指定位置满足过滤条件f并且不等于ex的min-max张卡
	Duel.SelectTarget(tp,c11881272.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的连锁的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置效果处理时的处理函数
function c11881272.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前连锁的所有的对象卡
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c11881272.eqfilter(tc) then
		-- 把c1作为玩家player的装备卡装备给c2
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备对象限制过滤函数
function c11881272.eqlimit(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x8)
end
-- 装备怪兽攻击力上升原本守备力数值的计算函数
function c11881272.atkval(e,c)
	return e:GetHandler():GetEquipTarget():GetBaseDefense()
end
-- 装备怪兽攻击力上升原本守备力数值的触发条件
function c11881272.atkcon(e)
	-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
-- 场地魔法卡发动过滤函数
function c11881272.actfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 设置发动时的处理函数
function c11881272.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11881272.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 检查玩家在当前阶段是否有操作（是否处于阶段开始时，如七皇之剑）
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
-- 设置发动时的处理函数
function c11881272.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家player发送提示信息，提示内容为desc
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11881272,2))  --"请选择要发动的场地魔法卡"
	-- 为玩家player注册全局环境下的标识效果，并返回这个效果
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,11881272,RESET_CHAIN,0,1) end
	-- 让玩家sel_player选择以player来看的指定位置满足过滤条件f并且不等于ex的min-max张卡
	local g=Duel.SelectMatchingCard(tp,c11881272.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 手动reset玩家player的 code 标识效果
	Duel.ResetFlagEffect(tp,11881272)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		-- 为玩家player注册全局环境下的标识效果，并返回这个效果
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,11881272,RESET_CHAIN,0,1) end
		local b=te:IsActivatable(tp,true,true)
		if b then
			-- 手动reset玩家player的 code 标识效果
			Duel.ResetFlagEffect(tp,11881272)
			-- 返回玩家player的场上位于location序号为seq的卡
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				-- 以reason原因把targets送去墓地，返回值是实际被操作的数量
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果，使之后的效果处理视为不同时处理，此函数会造成错时点
				Duel.BreakEffect()
			end
			-- 让玩家move_player把c移动的target_player的场上
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 以eg,ep,ev,re,r,rp触发一个时点 code
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
-- 攻击破坏对方怪兽时的触发条件
function c11881272.chacon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断攻击怪兽是否满足继续攻击的条件
	return Duel.GetAttacker()==ec and ec:IsRelateToBattle() and ec:IsStatus(STATUS_OPPO_BATTLE) and ec:IsChainAttackable()
end
-- 设置发动时的处理函数
function c11881272.chacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以reason原因把targets送去墓地，返回值是实际被操作的数量
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置发动时的处理函数
function c11881272.chaop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击卡[或卡片c]可以再进行1次攻击
	Duel.ChainAttack()
end
