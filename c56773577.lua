--ネクロバレーの神殿
-- 效果：
-- ①：只要「守墓」怪兽以及「王家长眠之谷」在场上存在，对方场上的怪兽的攻击力·守备力下降500。
-- ②：自己的场地区域没有卡存在的场合，1回合1次，自己·对方的主要阶段才能发动。从自己的手卡·墓地选1张「王家长眠之谷」发动。
-- ③：这张卡被对方的效果破坏送去墓地的场合才能发动。从卡组选「王家长眠之谷的神殿」以外的1张「王家长眠之谷」魔法·陷阱卡在自己场上盖放。
function c56773577.initial_effect(c)
	-- 王家长眠之谷的神殿 的卡片发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为不在伤害计算后
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：只要「守墓」怪兽以及「王家长眠之谷」在场上存在，对方场上的怪兽的攻击力·守备力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c56773577.atkcon)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己的场地区域没有卡存在的场合，1回合1次，自己·对方的主要阶段才能发动。从自己的手卡·墓地选1张「王家长眠之谷」发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56773577,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetCondition(c56773577.accon)
	e4:SetTarget(c56773577.actg)
	e4:SetOperation(c56773577.acop)
	c:RegisterEffect(e4)
	-- ③：这张卡被对方的效果破坏送去墓地的场合才能发动。从卡组选「王家长眠之谷的神殿」以外的1张「王家长眠之谷」魔法·陷阱卡在自己场上盖放。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(56773577,1))
	e5:SetCategory(CATEGORY_SSET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c56773577.setcon)
	e5:SetTarget(c56773577.settg)
	e5:SetOperation(c56773577.setop)
	c:RegisterEffect(e5)
end
-- 过滤条件：表侧表示的「守墓」怪兽
function c56773577.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2e)
end
-- 攻击力·守备力下降效果的适用条件：场上有「守墓」怪兽以及「王家长眠之谷」存在
function c56773577.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只表侧表示的「守墓」怪兽
	return Duel.IsExistingMatchingCard(c56773577.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且场上存在「王家长眠之谷」
		and Duel.IsEnvironment(47355498)
end
-- 效果②的发动条件：自己·对方的主要阶段，且自己的场地区域没有卡存在
function c56773577.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段1或主要阶段2
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 并且自己的场地区域没有卡存在
		and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,0,1,nil)
end
-- 过滤条件：手卡·墓地中可以发动的「王家长眠之谷」
function c56773577.filter(c,tp)
	return c:IsCode(47355498) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果②的发动准备（检查手卡·墓地是否存在可发动的「王家长眠之谷」）
function c56773577.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少1张满足发动条件的「王家长眠之谷」
	if chk==0 then return Duel.IsExistingMatchingCard(c56773577.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 效果②的效果处理：从手卡·墓地选1张「王家长眠之谷」发动（若场地区域已有卡则先送去墓地）
function c56773577.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡或墓地选择1张不受「王家长眠之谷」影响且满足发动条件的「王家长眠之谷」
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56773577.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 因规则将原本的场地卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使后续的移动到场上处理不与送去墓地同时进行
			Duel.BreakEffect()
		end
		-- 将选中的「王家长眠之谷」表侧表示移动到自己的场地区域并适用其效果
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发场地卡发动的相关事件
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
-- 效果③的发动条件：这张卡在自己的控制下被对方的效果破坏并送去墓地
function c56773577.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 过滤条件：卡组中「王家长眠之谷的神殿」以外的「王家长眠之谷」魔法·陷阱卡，且该卡可以盖放
function c56773577.setfilter(c)
	return c:IsSetCard(0x91) and not c:IsCode(56773577) and c:IsSSetable()
end
-- 效果③的发动准备（检查卡组中是否存在可盖放的目标卡）
function c56773577.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「王家长眠之谷」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56773577.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果③的效果处理：从卡组选1张满足条件的「王家长眠之谷」魔法·陷阱卡在自己场上盖放
function c56773577.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「王家长眠之谷」魔法·陷阱卡
	local tc=Duel.SelectMatchingCard(tp,c56773577.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
