--トロイメア・ゴブリン
-- 效果：
-- 卡名不同的怪兽2只
-- ①：这张卡在自己回合连接召唤的场合，丢弃1张手卡才能发动。这个效果的发动时这张卡是互相连接状态的场合，自己可以抽1张。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以从手卡把1只怪兽在作为这张卡所连接区的自己场上召唤。
-- ②：只要这张卡在怪兽区域存在，双方不能把自己场上的互相连接状态的怪兽作为效果的对象。
function c39064822.initial_effect(c)
	-- 添加连接召唤手续，要求使用2个连接素材，且连接素材的卡名不能重复
	aux.AddLinkProcedure(c,nil,2,2,c39064822.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡在自己回合连接召唤的场合，丢弃1张手卡才能发动。这个效果的发动时这张卡是互相连接状态的场合，自己可以抽1张。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以从手卡把1只怪兽在作为这张卡所连接区的自己场上召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39064822,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39064822.sumcon)
	e1:SetCost(c39064822.sumcost)
	e1:SetTarget(c39064822.sumtg)
	e1:SetOperation(c39064822.sumop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，双方不能把自己场上的互相连接状态的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c39064822.tgtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 连接素材的卡名不能重复的判断函数
function c39064822.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 连接召唤成功且为自己的回合时才能发动
function c39064822.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 连接召唤成功且为自己的回合时才能发动
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and Duel.GetTurnPlayer()==tp
end
-- 丢弃1张手卡作为发动cost
function c39064822.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有至少1张可丢弃的手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果的发动条件和目标
function c39064822.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以通常召唤、是否可以额外召唤、是否已使用过此效果
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,39064822)==0 end
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end
-- 若满足条件则询问是否抽卡
function c39064822.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若满足条件则询问是否抽卡
	if e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 若满足条件则询问是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(39064822,1)) then  --"是否抽卡？"
		-- 执行抽1张卡的操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	-- 若已使用过此效果则不重复执行
	if Duel.GetFlagEffect(tp,39064822)~=0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- ①：这张卡在自己回合连接召唤的场合，丢弃1张手卡才能发动。这个效果的发动时这张卡是互相连接状态的场合，自己可以抽1张。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以从手卡把1只怪兽在作为这张卡所连接区的自己场上召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39064822,2))  --"使用「梦幻崩影·哥布林」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetLabel(fid)
	e1:SetCondition(c39064822.sumcon2)
	e1:SetValue(c39064822.sumval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使玩家在主要阶段可以额外召唤一次
	Duel.RegisterEffect(e1,tp)
	-- 注册标识效果，防止此效果重复使用
	Duel.RegisterFlagEffect(tp,39064822,RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为当前哥布林的field ID
function c39064822.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID()==e:GetLabel()
end
-- 设置额外召唤的召唤区域
function c39064822.sumval(e,c)
	local c=e:GetHandler()
	local sumzone=c:GetLinkedZone()
	local relzone=-bit.lshift(1,c:GetSequence())
	return 0,sumzone,relzone
end
-- 判断目标怪兽是否为互相连接状态
function c39064822.tgtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
