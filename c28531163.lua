--黙歯録
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，对方场上的卡数量的龋齿指示物给这张卡放置。
-- ②：以对方场上1只表侧表示怪兽为对象，把自己场上最多4个龋齿指示物取除才能发动。取除的指示物数量的以下效果对那只怪兽适用。
-- ●1个：攻击力下降500。
-- ●2个：攻击力变成0。
-- ●3个：效果无效。
-- ●4个：破坏。
local s,id,o=GetID()
-- 初始化效果，设置卡名的指示物允许添加，并创建两个效果：①发动时放置指示物；②起动效果，消耗指示物对对方怪兽造成相应效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x6f)
	-- 效果①：作为这张卡的发动时的效果处理，对方场上的卡数量的龋齿指示物给这张卡放置
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：以对方场上1只表侧表示怪兽为对象，把自己场上最多4个龋齿指示物取除才能发动。取除的指示物数量的以下效果对那只怪兽适用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"选效果发动"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.mentioned_counter={
	[0x6f]=true,
}
-- 效果①的发动时处理函数，计算对方场上的卡数量并检查是否可以添加相应数量的指示物
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡的数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 判断是否满足添加指示物的条件：对方场上有卡且自己能添加对应数量的指示物
	if chk==0 then return ct>0 and Duel.IsCanAddCounter(tp,0x6f,ct,e:GetHandler()) end
	-- 设置连锁操作信息，提示将要放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x6f)
end
-- 效果①的发动时处理函数，实际执行放置指示物的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的卡的数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if c:IsRelateToChain() and ct>0 then
		c:AddCounter(0x6f,ct)
	end
end
-- 效果②的发动时处理函数，判断是否可以消耗指示物并对对方怪兽进行指定操作
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否可以消耗1个龋齿指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x6f,1,REASON_COST)
		-- 判断对方场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方场上的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为目标
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	-- 判断是否可以消耗1个龋齿指示物作为代价
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x6f,1,REASON_COST)
	-- 判断是否可以消耗2个龋齿指示物作为代价且目标怪兽攻击力不为0
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x6f,2,REASON_COST) and not tc:IsAttack(0)
	-- 判断是否可以消耗3个龋齿指示物作为代价且目标怪兽是效果怪兽
	local b3=Duel.IsCanRemoveCounter(tp,1,0,0x6f,3,REASON_COST) and aux.NegateEffectMonsterFilter(tc)
	-- 判断是否可以消耗4个龋齿指示物作为代价
	local b4=Duel.IsCanRemoveCounter(tp,1,0,0x6f,4,REASON_COST)
	-- 根据可消耗的指示物数量选择具体发动哪种效果
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"下降攻击力"
			{b2,aux.Stringid(id,2),2},  --"攻击力变成0"
			{b3,aux.Stringid(id,3),3},  --"效果无效"
			{b4,aux.Stringid(id,4),4})  --"破坏"
	-- 移除指定数量的龋齿指示物作为代价
	Duel.RemoveCounter(tp,1,0,0x6f,op,REASON_COST)
	e:SetLabel(op)
	if op==1 or op==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	elseif op==3 then
		e:SetCategory(CATEGORY_DISABLE)
	elseif op==4 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置连锁操作信息，提示将要破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	end
end
-- 效果②的处理函数，根据选择的效果类型对目标怪兽施加相应效果
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or not tc:IsType(TYPE_MONSTER) then return end
	if e:GetLabel()==1 then
		if tc:IsFaceup() then
			-- 使目标怪兽攻击力下降500
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-500)
			tc:RegisterEffect(e1)
		end
	elseif e:GetLabel()==2 then
		if tc:IsFaceup() then
			-- 使目标怪兽攻击力变成0
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif e:GetLabel()==3 then
		if tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使目标怪兽的效果被无效化
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	elseif e:GetLabel()==4 then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
