--魔界劇団－サッシー・ルーキー
-- 效果：
-- ←2 【灵摆】 2→
-- ①：自己场上的「魔界剧团」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡1回合只有1次不会被战斗·效果破坏。
-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「魔界剧团-莽撞新人」以外的1只4星以下的「魔界剧团」怪兽特殊召唤。
-- ③：这张卡在灵摆区域被破坏的场合，以对方场上1只4星以下的怪兽为对象才能发动。那只怪兽破坏。
function c51028231.initial_effect(c)
	-- 给此卡添加灵摆怪兽属性，使其可作为灵摆卡在灵摆区发动并获得灵摆召唤相关设定。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的「魔界剧团」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c51028231.reptg)
	e1:SetValue(c51028231.repval)
	e1:SetOperation(c51028231.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡1回合只有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c51028231.indct)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「魔界剧团-莽撞新人」以外的1只4星以下的「魔界剧团」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51028231,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c51028231.spcon)
	e3:SetTarget(c51028231.sptg)
	e3:SetOperation(c51028231.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡在灵摆区域被破坏的场合，以对方场上1只4星以下的怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51028231,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCondition(c51028231.descon)
	e4:SetTarget(c51028231.destg)
	e4:SetOperation(c51028231.desop)
	c:RegisterEffect(e4)
end
-- 筛选被破坏的怪兽：须为表侧表示、我方场上的「魔界剧团」怪兽，且因战斗或对方效果被破坏，且不是已被代替破坏的情况。
function c51028231.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and c:IsSetCard(0x10ec) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动条件：存在满足条件的己方「魔界剧团」怪兽将被破坏，且此卡本身可被破坏且未被预定破坏。
function c51028231.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c51028231.filter,1,nil,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否用这张卡代替破坏（选择是则发动）。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏的判断函数：对每个将被破坏的怪兽，判断其是否满足代破条件，若满足则此卡代替其破坏。
function c51028231.repval(e,c)
	return c51028231.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏的处理：将灵摆区的这张卡破坏，以代替符合条件的怪兽被破坏。
function c51028231.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行破坏这张卡，破坏原因标记为效果+代替，完成代替破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 判断本次受到的破坏是否包含战斗或效果破坏原因，若是则本次不被破坏效果适用。
function c51028231.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果发动条件：此卡在怪兽区域被对方的效果破坏，或被战斗破坏。
function c51028231.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)) or c:IsReason(REASON_BATTLE)
end
-- 检索条件：卡组中「魔界剧团」怪兽、4星以下、卡名不是「魔界剧团-莽撞新人」且可以被特殊召唤。
function c51028231.spfilter(c,e,tp)
	return c:IsSetCard(0x10ec) and c:IsLevelBelow(4) and not c:IsCode(51028231) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标条件：自己怪兽区域有空位，且卡组中存在符合条件的「魔界剧团」怪兽；满足则设置特殊召唤操作信息。
function c51028231.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己怪兽区域是否有可以特殊召唤的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在1张以上符合条件的「魔界剧团」怪兽。
		and Duel.IsExistingMatchingCard(c51028231.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁包含从卡组特殊召唤1只怪兽的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 特殊召唤的处理：仍有空位时，从卡组选择1只符合条件的「魔界剧团」怪兽，表侧表示特殊召唤到自己场上。
function c51028231.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认有可用空位，若无则直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1张符合条件的「魔界剧团」怪兽。
	local g=Duel.SelectMatchingCard(tp,c51028231.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件：此卡在灵摆区域被效果破坏。
function c51028231.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_PZONE)
end
-- 对象候选：对方场上的表侧表示怪兽，且4星以下。
function c51028231.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 取对象处理：确认对方场上有符合条件的怪兽，选择1只作为对象，并设置破坏操作信息。
function c51028231.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c51028231.desfilter(chkc) end
	-- 确认对方场上是否存在可以成为对象的表侧表示4星以下怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51028231.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c51028231.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁包含破坏该对象的效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏处理：若对象仍与此效果关联，则把对象破坏。
function c51028231.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁处理中选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽破坏，破坏原因为效果。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
