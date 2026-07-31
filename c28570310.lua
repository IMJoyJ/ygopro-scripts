--魔導獣 ガルーダ
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合，以这张卡以外的场上1张魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：对方对怪兽的召唤·特殊召唤成功时，把自己场上3个魔力指示物取除才能发动。这张卡从手卡特殊召唤。那之后，对方召唤·特殊召唤的那些怪兽回到持有者手卡。
-- ②：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
function c28570310.initial_effect(c)
	-- 为当前卡片启用灵摆怪兽属性，使其能够进行灵摆召唤和发动灵摆卡。
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合，以这张卡以外的场上1张魔法·陷阱卡为对象才能发动。那张卡和这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28570310,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28570310)
	e1:SetCondition(c28570310.descon)
	e1:SetTarget(c28570310.destg)
	e1:SetOperation(c28570310.desop)
	c:RegisterEffect(e1)
	-- 创建一个效果，用于实现破坏对方魔法/陷阱卡的灵摆效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 将连锁发生时这张卡在场上的状态记录下来，用于后续的判断。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 创建一个持续、辅助型的效果，监听连锁发动事件，并在特定条件下给这张卡添加魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c28570310.acop)
	c:RegisterEffect(e3)
	-- ①：对方对怪兽的召唤·特殊召唤成功时，把自己场上3个魔力指示物取除才能发动。这张卡从手卡特殊召唤。那之后，对方召唤·特殊召唤的那些怪兽回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28570310,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,28570311)
	e4:SetCondition(c28570310.spcon)
	e4:SetCost(c28570310.spcost)
	e4:SetTarget(c28570310.sptg)
	e4:SetOperation(c28570310.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
c28570310.mentioned_counter={
	[0x1]=true,
}
-- 判断当前玩家的灵摆区域是否为空
function c28570310.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家的灵摆区域是否为空
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 设置目标选择函数，用于选择要破坏的魔法/陷阱卡。
function c28570310.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return c:IsDestructable()
		-- 检查是否有满足条件的魔法/陷阱卡可以被选为目标。
		and Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择一张魔法或陷阱卡作为破坏对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,TYPE_SPELL+TYPE_TRAP)
	g:AddCard(c)
	-- 设置当前连锁的操作信息，表明这是一个破坏效果，并指定目标卡和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将选定的魔法/陷阱卡和这张卡一起破坏。
function c28570310.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取第一个被选中的目标卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 以效果为理由破坏目标卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 创建一个辅助效果，监听连锁发动事件，并在特定条件下给这张卡添加魔力指示物。
function c28570310.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 定义一个过滤函数，用于判断一张卡是否是召唤者为指定玩家的怪兽。
function c28570310.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 设置特殊召唤效果的触发条件：对方召唤/特殊召唤成功，且场上有满足条件的怪兽。
function c28570310.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28570310.cfilter,1,nil,1-tp)
end
-- 设置特殊召唤效果的费用：移除自身场上3个魔力指示物。
function c28570310.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除足够的魔力指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,3,REASON_COST) end
	-- 从自身场上移除3个魔力指示物作为费用。
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_COST)
end
-- 设置特殊召唤效果的目标选择函数，用于选择对方被召唤/特殊召唤的怪兽。
function c28570310.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(c28570310.cfilter,nil,1-tp):Filter(Card.IsAbleToHand,nil)
	-- 检查是否有可用的怪兽区域以及当前卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:GetCount()>0 end
	-- 将目标卡设置为连锁的对象
	Duel.SetTargetCard(eg)
	-- 设置当前连锁的操作信息，表明这是一个特殊召唤效果和回手牌效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置当前连锁的操作信息，表明这是一个特殊召唤效果和回手牌效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行特殊召唤效果：将这张卡从手卡特殊召唤到场上，并将对方被召唤/特殊召唤的怪兽送回持有者手卡。
function c28570310.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前效果是否与卡片相关联，并且特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=eg:Filter(c28570310.cfilter,nil,1-tp):Filter(Card.IsRelateToEffect,nil,e)
		if g:GetCount()>0 then
			-- 中断当前效果的处理流程，防止连锁效应的发生。
			Duel.BreakEffect()
			-- 将对方被召唤/特殊召唤的怪兽送回持有者手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
