--真魔六武衆－シエン
-- 效果：
-- 战士族调整＋调整以外的「六武众」怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1只「六武众」怪兽或「紫炎」效果怪兽加入手卡。
-- ②：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤程序、启用复活限制，并注册三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只战士族调整和1只调整以外的六武众怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),aux.NonTuner(Card.IsSetCard,0x103d),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1只「六武众」怪兽或「紫炎」效果怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
end
-- 效果条件：确认该卡是通过同调召唤方式特殊召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索过滤器：满足六武众或紫炎效果怪兽条件的怪兽
function s.thfilter(c)
	return (c:IsSetCard(0x103d) or c:IsSetCard(0x20) and c:IsType(TYPE_EFFECT)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标：检查是否存在满足条件的卡牌并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足检索条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为将卡牌加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：提示选择卡牌并将其加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足检索条件的卡牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果条件：确认是对方发动怪兽效果且该卡未在战斗中被破坏
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是对方发动怪兽效果且该卡未在战斗中被破坏且该连锁可被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果目标：设置操作信息为无效发动并破坏目标怪兽
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效对方发动并破坏其怪兽
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以无效对方发动并确认目标怪兽是否可破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 代替破坏过滤器：满足可破坏且未被确认破坏状态的怪兽
function s.repfilter(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏目标：检查该卡是否因战斗或效果破坏且场上存在可代替破坏的怪兽
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查场上是否存在可代替破坏的怪兽
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择代替破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择场上可代替破坏的怪兽
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏处理：取消怪兽的确认破坏状态并将其破坏
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
