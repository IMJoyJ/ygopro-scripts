--オルターガイスト・ホーンデッドロック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。「幻变骚灵」卡的效果盖放的这张卡在盖放的回合也能发动。
-- ①：作为这张卡的发动时的效果处理，从手卡把1只「幻变骚灵」怪兽送去墓地。
-- ②：对方把陷阱卡发动时，从手卡把1只「幻变骚灵」怪兽送去墓地才能发动。那个效果无效并破坏。
function c2547033.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：作为这张卡的发动时的效果处理，从手卡把1只「幻变骚灵」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,2547033)
	e1:SetTarget(c2547033.target)
	e1:SetOperation(c2547033.operation)
	c:RegisterEffect(e1)
	-- ②：对方把陷阱卡发动时，从手卡把1只「幻变骚灵」怪兽送去墓地才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,2547034)
	e2:SetCondition(c2547033.discon)
	e2:SetCost(c2547033.discost)
	e2:SetTarget(c2547033.distg)
	e2:SetOperation(c2547033.disop)
	c:RegisterEffect(e2)
	-- 「幻变骚灵」卡的效果盖放的这张卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2547033,1))  --"适用「幻变骚灵的闹鬼死锁」的效果来发动"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(c2547033.actcon)
	c:RegisterEffect(e3)
	if not c2547033.global_check then
		c2547033.global_check=true
		-- 「幻变骚灵」卡的效果盖放的这张卡在盖放的回合也能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c2547033.checkop)
		-- 将全局检查效果ge1注册到游戏环境中，监听EVENT_SSET事件；每当有卡被盖放时执行c2547033.checkop，用于判断该盖放是否由「幻变骚灵」卡的效果产生。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有卡被盖放时，若该盖放行为的效果来源卡属于「幻变骚灵」系列，则为被盖放的卡注册编号2547033的标记，该标记在卡片离场、回合结束等标准重置时清除，记录该卡是由「幻变骚灵」卡的效果盖放的。
function c2547033.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(0x103) then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(2547033,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 筛选手卡中满足以下条件的卡：是怪兽卡、属于「幻变骚灵」字段（0x103）、且可以被效果送去墓地；作为①效果从手卡送去墓地的对象过滤条件。
function c2547033.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x103) and c:IsAbleToGrave()
end
-- ①效果的发动条件检查和操作信息设置：在发动时确认手卡中存在符合tgfilter的「幻变骚灵」怪兽，并设置操作信息为将从手卡把1张卡送去墓地。
function c2547033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认自己的手卡中是否有至少1只符合条件的「幻变骚灵」怪兽；若没有则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2547033.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设定操作信息，声明本效果处理会涉及“送去墓地”分类，预计从当前玩家手卡选1张卡送去墓地，具体卡在处理时选择，因此对象先设为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ①效果的实际处理：让当前玩家从手卡选择1只符合条件的「幻变骚灵」怪兽，并将它因效果送去墓地。
function c2547033.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示选择“请选择要送去墓地的卡”的提示，供选卡界面使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从手卡中筛选并选择1张符合tgfilter条件的「幻变骚灵」怪兽，作为①效果送去墓地的对象。
	local g=Duel.SelectMatchingCard(tp,c2547033.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张卡以“效果”为由送去墓地，完成①效果中从手卡把「幻变骚灵」怪兽送去墓地的动作。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前连锁的发动者是对方（ep==1-tp），且对方发动的卡是陷阱卡，并且属于陷阱卡的“卡的发动”（EFFECT_TYPE_ACTIVATE）。
function c2547033.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 筛选手卡中可以作为②效果代价丢弃的卡：必须是怪兽卡、属于「幻变骚灵」字段、且能作为代价送去墓地。
function c2547033.discfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x103) and c:IsAbleToGraveAsCost()
end
-- ②效果的代价定义：发动前检查手卡是否有可丢弃的「幻变骚灵」怪兽，若有则从手卡丢弃1只符合条件的「幻变骚灵」怪兽作为代价。
function c2547033.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己手卡中是否存在至少1只可作为代价丢弃的「幻变骚灵」怪兽，否则②效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2547033.discfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择并丢弃1只符合discfilter条件的「幻变骚灵」怪兽去墓地，丢弃原因记为代价（REASON_COST）。
	Duel.DiscardHand(tp,c2547033.discfilter,1,1,REASON_COST,nil)
end
-- ②效果的目标和操作信息设置：将对方正在发动的陷阱卡作为无效对象；若该卡仍可被破坏且与发动效果有联系，则同时将其作为破坏对象。
function c2547033.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：本次效果包含“无效”分类，对象为对方发动的陷阱卡（eg），预定使该卡效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设定操作信息：本次效果同时包含“破坏”分类，对象为同一张对方陷阱卡（eg），预定在其仍可被破坏时将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果的实际处理：先使对方发动的陷阱卡效果无效；若无效成功且该卡仍与本次连锁相关，则将其破坏，完成“那个效果无效并破坏”。
function c2547033.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效化并检查联系：Duel.NegateEffect(ev)使对方陷阱卡效果无效，同时判断该卡是否仍与所发动的效果相关（未离场或重置），只有满足时才继续破坏。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动中的那张陷阱卡以“效果”为由破坏，完成②效果中的破坏部分。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断本卡是否带有标记2547033，即本卡是否由「幻变骚灵」卡的效果盖放，以此作为“盖放的回合也能发动”的附加条件。
function c2547033.actcon(e)
	return e:GetHandler():GetFlagEffect(2547033)>0
end
