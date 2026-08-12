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
-- 初始化卡片效果：允许这张卡放置龋齿指示物（0x6f），并注册两个效果——e1为卡的发动效果（放置指示物），e2为在魔法与陷阱区域取对象的起动效果（取除指示物对对方怪兽适用效果）。
function s.initial_effect(c)
	c:EnableCounterPermit(0x6f)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，对方场上的卡数量的龋齿指示物给这张卡放置。
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
-- 卡发动的目标处理：统计对方场上的卡数量，检查这张卡能否放置相应数量的龋齿指示物，并设置指示物放置的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计对方场上（怪兽区和魔法与陷阱区域）的卡的数量。
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 效果发动条件检查：对方场上至少有1张卡，且这张卡可以放置该数量的龋齿指示物。
	if chk==0 then return ct>0 and Duel.IsCanAddCounter(tp,0x6f,ct,e:GetHandler()) end
	-- 设置本次效果处理的操作信息为放置指示物，数量为对方场上的卡数量。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x6f)
end
-- 卡发动时的效果处理：若这张卡与连锁关联且对方场上有卡，则将对方场上的卡数量的龋齿指示物给这张卡放置。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次统计处理时点对方场上的卡的数量，作为实际放置指示物的数量。
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if c:IsRelateToChain() and ct>0 then
		c:AddCounter(0x6f,ct)
	end
end
-- ②效果的目标处理：取对象检查（对象须为对方怪兽区域的表侧表示怪兽），发动条件检查，然后选取对象、让玩家选择要取除的指示物数量并设置相应的效果分类。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件检查：自己场上存在可以取除至少1个龋齿指示物作为代价的指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x6f,1,REASON_COST)
		-- 发动条件检查：对方怪兽区域存在可以作为效果对象的表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示，提示请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方怪兽区域1只表侧表示怪兽作为效果对象并记录下来。
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	-- 判断能否取除1个龋齿指示物作为代价，对应「●1个：攻击力下降500」的选项。
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x6f,1,REASON_COST)
	-- 判断能否取除2个龋齿指示物作为代价，且对象怪兽的攻击力不是0，对应「●2个：攻击力变成0」的选项。
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x6f,2,REASON_COST) and not tc:IsAttack(0)
	-- 判断能否取除3个龋齿指示物作为代价，且对象怪兽是可以被无效的表侧表示效果怪兽，对应「●3个：效果无效」的选项。
	local b3=Duel.IsCanRemoveCounter(tp,1,0,0x6f,3,REASON_COST) and aux.NegateEffectMonsterFilter(tc)
	-- 判断能否取除4个龋齿指示物作为代价，对应「●4个：破坏」的选项。
	local b4=Duel.IsCanRemoveCounter(tp,1,0,0x6f,4,REASON_COST)
	-- 让玩家从以上四个有效选项中选择要取除的指示物数量（即要适用的效果）。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"下降攻击力"
			{b2,aux.Stringid(id,2),2},  --"攻击力变成0"
			{b3,aux.Stringid(id,3),3},  --"效果无效"
			{b4,aux.Stringid(id,4),4})  --"破坏"
	-- 把选择数量的龋齿指示物从自己场上取除作为代价。
	Duel.RemoveCounter(tp,1,0,0x6f,op,REASON_COST)
	e:SetLabel(op)
	if op==1 or op==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	elseif op==3 then
		e:SetCategory(CATEGORY_DISABLE)
	elseif op==4 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 当选择取除4个指示物时，设置本次连锁的操作信息为破坏对象怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	end
end
-- ②效果的处理：根据取除的指示物数量，对对象怪兽分别适用攻击力下降500、攻击力变成0、效果无效或破坏的效果。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽（即②效果选择的对方场上表侧表示怪兽）。
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
			-- 将与对象怪兽相关的连锁全部无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- ●3个：效果无效（使对象怪兽的效果无效）。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- ●3个：效果无效（同时使对象怪兽已经发动的效果无效）。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	elseif e:GetLabel()==4 then
		-- ●4个：破坏（将对象怪兽破坏）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
