--ローグ・オブ・エンディミオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合发动。给这张卡放置1个魔力指示物。
-- ②：把这张卡1个魔力指示物取除，从手卡丢弃1只魔法师族怪兽才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。这个回合，自己不能把这个效果盖放的卡以及那些同名卡的效果发动。
function c44640691.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。给这张卡放置1个魔力指示物。
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
	-- ②：把这张卡1个魔力指示物取除，从手卡丢弃1只魔法师族怪兽才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。这个回合，自己不能把这个效果盖放的卡以及那些同名卡的效果发动。
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
-- 设置连锁操作信息，表明将要放置1个魔力指示物
function c44640691.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明将要放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 将魔力指示物放置到指定卡上
function c44640691.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 过滤函数，用于判断手卡中是否存在魔法师族且可丢弃的怪兽
function c44640691.costfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDiscardable()
end
-- 判断是否满足发动条件，即是否能取除1个魔力指示物并从手卡丢弃1只魔法师族怪兽
function c44640691.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST)
		-- 判断是否满足发动条件，即是否能取除1个魔力指示物并从手卡丢弃1只魔法师族怪兽
		and Duel.IsExistingMatchingCard(c44640691.costfilter,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
	-- 从手卡丢弃1只魔法师族怪兽
	Duel.DiscardHand(tp,c44640691.costfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 过滤函数，用于判断卡组中是否存在可盖放的永续魔法卡
function c44640691.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 设置连锁操作信息，表明将要从卡组选择1张永续魔法卡盖放
function c44640691.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置连锁操作信息，表明将要从卡组选择1张永续魔法卡盖放
	if chk==0 then return Duel.IsExistingMatchingCard(c44640691.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 选择并盖放一张永续魔法卡，并设置效果限制
function c44640691.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c44640691.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功盖放，则设置效果限制
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 设置效果限制，使自己不能发动同名卡的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c44640691.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果限制
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的判断函数，用于判断是否为同名卡的效果
function c44640691.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
