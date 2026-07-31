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
-- 定义一个函数s.initial_effect(c)，用于注册卡片的效果。首先允许该卡使用指示物，然后创建两个效果：e1用于放置龋齿指示物，e2用于选择并应用对目标怪兽的效果。
function s.initial_effect(c)
	c:EnableCounterPermit(0x6f)
	-- ①：作为这张卡的发动时的效果处理，对方场上的卡数量的龋齿指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：以对方场上1只表侧表示怪兽为对象，把自己场上最多4个龋齿指示物取除才能发动。取除的指示物数量的以下效果对那只怪兽适用。
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
-- 定义一个函数s.target(e,tp,eg,ep,ev,re,r,rp,chk)，用于确定放置龋齿指示物的目标。它计算对方场上的卡片数量，并检查是否可以添加指示物。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方场上卡的数量。
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 在检查模式下（chk==0），返回如果对方场上有卡且可以向该卡添加龋齿指示物则为真。
	if chk==0 then return ct>0 and Duel.IsCanAddCounter(tp,0x6f,ct,e:GetHandler()) end
	-- 设置操作信息，表明正在添加指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x6f)
end
-- 定义一个函数s.activate(e,tp,eg,ep,ev,re,r,rp)，用于实际放置龋齿指示物。它计算对方场上的卡片数量，如果连锁未开始且有卡，则将相应数量的指示物添加到该卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次计算对方场上卡的数量。
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if c:IsRelateToChain() and ct>0 then
		c:AddCounter(0x6f,ct)
	end
end
-- 定义一个函数s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)，用于选择目标怪兽并确定要应用的效果。它检查连锁，然后允许玩家选择表侧表示的怪兽。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在检查模式下（chk==0），返回如果可以移除一个龋齿指示物则为真。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x6f,1,REASON_COST)
		-- 并且确认场上存在表侧表示的怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示，要求选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上的表侧表示怪兽中选择一个作为目标。
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	-- 检查是否可以移除一个龋齿指示物。
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x6f,1,REASON_COST)
	-- 检查是否可以移除两个龋齿指示物，并且目标怪兽不处于攻击状态。
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x6f,2,REASON_COST) and not tc:IsAttack(0)
	-- 检查是否可以移除三个龋齿指示物，并且目标怪兽可以被效果无效化。
	local b3=Duel.IsCanRemoveCounter(tp,1,0,0x6f,3,REASON_COST) and aux.NegateEffectMonsterFilter(tc)
	-- 检查是否可以移除四个龋齿指示物。
	local b4=Duel.IsCanRemoveCounter(tp,1,0,0x6f,4,REASON_COST)
	-- 使用aux.SelectFromOptions让玩家选择要应用的效果（降低攻击力、将攻击力变为0、使效果无效或破坏）。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"下降攻击力"
			{b2,aux.Stringid(id,2),2},  --"攻击力变成0"
			{b3,aux.Stringid(id,3),3},  --"效果无效"
			{b4,aux.Stringid(id,4),4})  --"破坏"
	-- 从卡片上移除选定的数量的龋齿指示物。
	Duel.RemoveCounter(tp,1,0,0x6f,op,REASON_COST)
	e:SetLabel(op)
	if op==1 or op==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	elseif op==3 then
		e:SetCategory(CATEGORY_DISABLE)
	elseif op==4 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置操作信息，表明正在进行破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	end
end
-- 定义一个函数s.tgop(e,tp,eg,ep,ev,re,r,rp)，用于应用所选的效果。它获取目标怪兽，并根据之前选择的指示物数量应用相应的效果（降低攻击力、将攻击力变为0、使效果无效或破坏）。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or not tc:IsType(TYPE_MONSTER) then return end
	if e:GetLabel()==1 then
		if tc:IsFaceup() then
			-- ●1个：攻击力下降500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-500)
			tc:RegisterEffect(e1)
		end
	elseif e:GetLabel()==2 then
		if tc:IsFaceup() then
			-- ●2个：攻击力变成0。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif e:GetLabel()==3 then
		if tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			-- 使和卡片c有关的连锁都无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- ●3个：效果无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- ●3个：效果无效。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	elseif e:GetLabel()==4 then
		-- ●4个：破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
