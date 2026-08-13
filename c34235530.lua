--真魔六武衆－シエン
-- 效果：
-- 战士族调整＋调整以外的「六武众」怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1只「六武众」怪兽或「紫炎」效果怪兽加入手卡。
-- ②：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只怪兽破坏。
local s,id,o=GetID()
-- 注册真魔六武众-紫炎的同调召唤手续，以及①检索、②发动无效并破坏、③代替破坏这三个效果。
function s.initial_effect(c)
	-- 设定同调召唤素材为：战士族调整＋调整以外的「六武众」怪兽1只以上。
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
-- ①效果的发动条件：这张卡为同调召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的检索过滤：满足「六武众」怪兽或「紫炎」效果怪兽，且是怪兽并能加入手卡。
function s.thfilter(c)
	return (c:IsSetCard(0x103d) or c:IsSetCard(0x20) and c:IsType(TYPE_EFFECT)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动目标：确认卡组·墓地存在符合条件的怪兽，并设置“加入手卡”的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己的卡组·墓地是否存在至少1只符合条件的「六武众」或「紫炎」效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置本次效果处理为从卡组·墓地检索1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从卡组·墓地选择1只符合条件的怪兽加入手卡，并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动者弹出“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 发动者从自己的卡组·墓地选择1张满足条件且不受王家长眠之谷影响的怪兽卡片。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入持有者手卡（省略player参数，默认回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：对手发动怪兽效果，这张卡自身未被战斗破坏，且该连锁可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方连锁发动的效果是否为怪兽效果、是否由对方发动、紫炎未被战斗破坏且连锁可被无效。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ②效果的目标处理：设置“无效发动”和“破坏”的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将无效对方的发动（对应“那个发动无效”）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果对方发动效果的那张卡可被破坏且仍与效果关联，则设置操作信息：将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方的发动，成功后将对应怪兽破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动已被无效，且原发动卡的怪兽仍与该效果关联，则继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动效果的怪兽（eg）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 代破效果的候选怪兽过滤：可被效果破坏，且尚未被标记为已确认破坏/战斗破坏。
function s.repfilter(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- ③代破触发条件：这张卡将被战斗或效果破坏，且不是因代破引起的破坏，并且自己场上存在其他可代替破坏的怪兽。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在1只除紫炎以外的可被破坏的怪兽作为代替破坏对象。
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问发动者是否发动③的代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 给发动者弹出“请选择要代替破坏的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 发动者选择自己场上1只除紫炎以外的可破坏怪兽作为代替破坏对象。
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- ③代破处理：将选择的代替破坏怪兽破坏，同时清除其“已确认破坏”标记。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以代替破坏的身份将之前选择的怪兽破坏（破坏原因为效果破坏+代替破坏）。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
