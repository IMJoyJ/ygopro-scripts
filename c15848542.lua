--ドラゴンメイド・ルフト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
function c15848542.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15848542,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15848542)
	e1:SetCost(c15848542.actcost)
	e1:SetTarget(c15848542.acttg)
	e1:SetOperation(c15848542.actop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c15848542.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15848542,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,15848543)
	e3:SetTarget(c15848542.sptg)
	e3:SetOperation(c15848542.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价处理：检查这张卡是否能够作为代价丢弃，若能则满足代价条件。
function c15848542.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 以“代价丢弃”的方式将这张卡从手卡送去墓地，完成①效果要求的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤出场上表侧表示的效果怪兽（包含原本种类就包含效果怪兽的卡），作为①效果的可选对象。
function c15848542.actfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT)
end
-- ①效果的发动时处理：确认场上有符合条件的表侧效果怪兽，并选择其中1只作为对象。
function c15848542.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15848542.actfilter(chkc) end
	-- 发动合法性检查：自己或对方场上是否存在至少1只表侧表示的效果怪兽可供选择作为对象。
	if chk==0 then return Duel.IsExistingTarget(c15848542.actfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家展示选择提示，要求其选择1只表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从双方场上选择1只表侧表示的效果怪兽，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c15848542.actfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：取得对象后，若对象仍与效果关联且表侧表示，则给对象附加‘不能发动场上效果’的封锁效果，持续到这个回合结束。
function c15848542.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤条件：判断怪兽是否为表侧表示的融合怪兽，用于②的抗性条件判定。
function c15848542.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- ②的抗性条件：自己场上存在表侧表示融合怪兽时，这张卡获得‘不会被效果破坏’的效果。
function c15848542.indcon(e)
	-- 具体条件判定：从自己场上检索是否存在至少1只表侧表示的融合怪兽。
	return Duel.IsExistingMatchingCard(c15848542.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡中的卡是「半龙女仆」字段、等级为3，并且可以被当前效果特殊召唤。
function c15848542.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果发动条件：这张卡能够回到手卡，自己场上有可用的怪兽区，且手卡中存在可特殊召唤的3星「半龙女仆」怪兽。
function c15848542.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 确认这张卡自身离开场上后仍至少有1个可用的怪兽区，用于之后特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0
		-- 确认手卡中存在至少1只满足特殊召唤条件的3星「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c15848542.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将‘这张卡回到手卡’这一处理内容登记到当前连锁的操作信息中。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 将‘从手卡特殊召唤1只怪兽’这一处理内容登记到当前连锁的操作信息中，并注明数量与位置。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：将这张卡送回手卡；如果送回成功且自己场上仍有空位，则从手卡选择1只3星「半龙女仆」怪兽表侧攻击表示特殊召唤。
function c15848542.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与③效果关联，若是则将其送回持有者手卡，并判断是否实际送回成功。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡已经在手卡，并且自己场上仍有可用的怪兽区，之后才继续特殊召唤。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示特殊召唤的选择提示，要求玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只满足条件的3星「半龙女仆」怪兽。
		local g=Duel.SelectMatchingCard(tp,c15848542.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
