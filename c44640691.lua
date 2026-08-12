--ローグ・オブ・エンディミオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合发动。给这张卡放置1个魔力指示物。
-- ②：把这张卡1个魔力指示物取除，从手卡丢弃1只魔法师族怪兽才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。这个回合，自己不能把这个效果盖放的卡以及那些同名卡的效果发动。
function c44640691.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合发动。给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44640691,0))  --"放置1个魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,44640691)
	e1:SetTarget(c44640691.addct)
	e1:SetOperation(c44640691.addc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡1个魔力指示物取除，从手卡丢弃1只魔法师族怪兽才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。这个回合，自己不能把这个效果盖放的卡以及那些同名卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44640691,1))  --"将永续魔法卡盖放"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetCountLimit(1,44640692)
	e3:SetCost(c44640691.setcost)
	e3:SetTarget(c44640691.settg)
	e3:SetOperation(c44640691.setop)
	c:RegisterEffect(e3)
end
c44640691.mentioned_counter={
	[0x1]=true,
}
-- ①效果的目标函数：该效果为必发效果（chk==0时直接返回true），并设置本次连锁要放置1个魔力指示物的操作信息
function c44640691.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁确定要给这张卡放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- ①效果的处理：若这张卡仍与该效果关联（仍在场上），则给这张卡放置1个魔力指示物
function c44640691.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 代价过滤函数：魔法师族且可以丢弃的手卡怪兽
function c44640691.costfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDiscardable()
end
-- ②效果的代价：检查这张卡能否取除1个魔力指示物，且手卡存在可以丢弃的魔法师族怪兽
function c44640691.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST)
		-- 且手卡中至少存在1只可以丢弃的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c44640691.costfilter,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
	-- 让玩家从手卡选择1只魔法师族怪兽丢弃，作为发动代价
	Duel.DiscardHand(tp,c44640691.costfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 盖放对象的过滤函数：可以盖放到魔法与陷阱区域的永续魔法卡
function c44640691.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- ②效果的目标函数：检查卡组中是否存在可以盖放的永续魔法卡
function c44640691.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中至少存在1张可以盖放的永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44640691.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的处理：提示玩家选择要盖放的卡，从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放，并注册本回合不能发动该卡及其同名卡效果的限制
function c44640691.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张可以盖放的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c44640691.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功选到卡且将其在自己的魔法与陷阱区域盖放成功
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个回合，自己不能把这个效果盖放的卡以及那些同名卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c44640691.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 把该发动限制效果注册给自己，直到回合结束阶段时解除
		Duel.RegisterEffect(e1,tp)
	end
end
-- 发动限制的判断函数：若正在发动的效果的处理者是该效果盖放的卡或其同名卡，则禁止发动
function c44640691.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
