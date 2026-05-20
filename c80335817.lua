--刻剣の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- ①：只要这张卡在灵摆区域存在，1回合1次，自己场上的灵摆怪兽不会被对方的效果破坏。
-- 【怪兽效果】
-- ①：只让手卡的这张卡灵摆召唤成功时才能发动。这张卡的攻击力变成原本攻击力的2倍。
-- ②：1回合1次，以场上1只怪兽为对象才能发动。那只怪兽和场上的这张卡直到下次的自己准备阶段除外。
local s,id,o=GetID()
-- 初始化函数，注册灵摆属性、灵摆效果（灵摆怪兽限次免受对方效果破坏）、怪兽效果①（单卡手卡灵摆召唤成功时攻击力翻倍）以及怪兽效果②（暂时除外自身和场上1只怪兽）
function c80335817.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本灵摆属性
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，1回合1次，自己场上的灵摆怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1)
	e2:SetTarget(c80335817.indtg)
	e2:SetValue(c80335817.indval)
	c:RegisterEffect(e2)
	-- ①：只让手卡的这张卡灵摆召唤成功时才能发动。这张卡的攻击力变成原本攻击力的2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c80335817.atkcon)
	e3:SetOperation(c80335817.atkop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，以场上1只怪兽为对象才能发动。那只怪兽和场上的这张卡直到下次的自己准备阶段除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c80335817.rmtg)
	e4:SetOperation(c80335817.rmop)
	c:RegisterEffect(e4)
end
-- 过滤出自己场上的灵摆怪兽作为免受破坏效果的影响对象
function c80335817.indtg(e,c)
	return c:IsType(TYPE_PENDULUM)
end
-- 判定破坏原因为对方玩家发动的效果
function c80335817.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
-- 判定是否仅有手牌中的这张卡灵摆召唤成功
function c80335817.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:GetCount()==1 and eg:GetFirst()==c
		and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 灵摆召唤成功时，使这张卡的攻击力变成原本攻击力的2倍
function c80335817.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判定自身和场上另一只怪兽是否可以被除外，并进行取对象操作
function c80335817.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 检查场上是否存在除自身以外可以被除外的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择场上1只可以被除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 设置除外操作的信息，包含2张卡（自身和选择的对象）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 将自身和对象怪兽暂时除外，并注册在下次自己准备阶段返回场上的延迟效果
function c80335817.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被选择为除外对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	-- 将自身和对象怪兽以效果原因暂时除外，并判断是否成功除外
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 获取本次操作实际被除外的卡片组
		local og=Duel.GetOperatedGroup()
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 直到下次的自己准备阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetCondition(c80335817.retcon)
		e1:SetOperation(c80335817.retop)
		-- 注册在准备阶段将除外卡片返回场上的全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有此卡效果标记（即被此效果暂时除外）的卡片
function c80335817.retfilter(c)
	return c:GetFlagEffect(80335817)~=0
end
-- 判定当前回合玩家是否为自己，用于在自己的准备阶段触发返回效果
function c80335817.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 在准备阶段将之前被暂时除外的卡片返回场上，若格子不足且两张卡属于同一玩家，则由该玩家选择其中一张先返回
function c80335817.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c80335817.retfilter,nil)
	if sg:GetCount()>1 and sg:GetClassCount(Card.GetPreviousControler)==1 then
		-- 获取返回卡片持有者场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(sg:GetFirst():GetPreviousControler(),LOCATION_MZONE)
		if ft==1 then
			-- 提示玩家选择要先回到场上的卡片
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(80335817,0))  --"请选择要回到场上的卡"
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			-- 将玩家选择的那一只怪兽返回到场上
			Duel.ReturnToField(tc)
			sg:RemoveCard(tc)
		end
	end
	local tc=sg:GetFirst()
	while tc do
		-- 将剩余被暂时除外的怪兽返回到场上
		Duel.ReturnToField(tc)
		tc=sg:GetNext()
	end
end
