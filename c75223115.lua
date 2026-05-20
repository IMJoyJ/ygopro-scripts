--Sin Territory
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「罪 世界」发动。只要这个效果发动的卡在场地区域存在，双方不能把场地区域的卡作为效果的对象。
-- ②：「罪」怪兽持有的「「罪」怪兽在场上只能有1只表侧表示存在」效果作为「「罪」怪兽每1种类在场上只能有1只表侧表示存在」适用。
-- ③：只在战斗阶段内场上的「罪」怪兽的效果无效化。
function c75223115.initial_effect(c)
	-- 在卡片中注册其效果中记有「罪 世界」的卡片密码
	aux.AddCodeList(c,27564031)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「罪 世界」发动。只要这个效果发动的卡在场地区域存在，双方不能把场地区域的卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c75223115.activate)
	c:RegisterEffect(e1)
	-- ②：「罪」怪兽持有的「「罪」怪兽在场上只能有1只表侧表示存在」效果作为「「罪」怪兽每1种类在场上只能有1只表侧表示存在」适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(75223115)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	-- ③：只在战斗阶段内场上的「罪」怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c75223115.discon)
	-- 设置效果的对象为「罪」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x23))
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以发动的「罪 世界」的条件函数
function c75223115.actfilter(c,tp)
	return c:IsCode(27564031) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 作为这张卡发动时的效果处理，从卡组发动「罪 世界」并赋予其不能成为效果对象的效果
function c75223115.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中满足发动条件的「罪 世界」卡片组
	local g=Duel.GetMatchingGroup(c75223115.actfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 若卡组中存在可发动的「罪 世界」，则由玩家选择是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(75223115,0)) then  --"是否发动场地？"
		-- 中断当前效果处理，使后续处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要放置到场上的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 将选中的「罪 世界」表侧表示移动到场地区域并适用其效果
		Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=sc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=sc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发场地魔法发动的相关事件时点
		Duel.RaiseEvent(sc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		-- 只要这个效果发动的卡在场地区域存在，双方不能把场地区域的卡作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetRange(LOCATION_FZONE)
		e1:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end
-- 判断当前是否处于战斗阶段的条件函数
function c75223115.discon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
