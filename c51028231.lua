--魔界劇団－サッシー・ルーキー
-- 效果：
-- ←2 【灵摆】 2→
-- ①：自己场上的「魔界剧团」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：这张卡1回合只有1次不会被战斗·效果破坏。
-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「魔界剧团-莽撞新人」以外的1只4星以下的「魔界剧团」怪兽特殊召唤。
-- ③：这张卡在灵摆区域被破坏的场合，以对方场上1只4星以下的怪兽为对象才能发动。那只怪兽破坏。
function c51028231.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
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
-- 过滤函数，用于判断场上的怪兽是否满足被破坏时可以代替破坏的条件（战斗或对方效果破坏且属于魔界剧团）
function c51028231.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and c:IsSetCard(0x10ec) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标判定函数，检查是否有符合条件的怪兽被破坏并确认该卡可被破坏
function c51028231.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c51028231.filter,1,nil,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的价值函数，返回是否满足代替破坏条件的怪兽
function c51028231.repval(e,c)
	return c51028231.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，将自身破坏
function c51028231.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替破坏原因破坏自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 判断该卡是否在战斗或效果破坏时不会被破坏
function c51028231.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 特殊召唤效果的发动条件函数，判断该卡是否因战斗或对方效果破坏而被破坏
function c51028231.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)) or c:IsReason(REASON_BATTLE)
end
-- 特殊召唤效果的过滤函数，筛选满足等级、种族和非自身条件的魔界剧团怪兽
function c51028231.spfilter(c,e,tp)
	return c:IsSetCard(0x10ec) and c:IsLevelBelow(4) and not c:IsCode(51028231) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标设定函数，检查是否有符合条件的怪兽可被特殊召唤
function c51028231.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可以进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c51028231.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张来自卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤符合条件的怪兽
function c51028231.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c51028231.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的发动条件函数，判断该卡是否因对方效果且在灵摆区域被破坏
function c51028231.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_PZONE)
end
-- 破坏效果的目标过滤函数，筛选对方场上的4星以下的怪兽
function c51028231.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 破坏效果的目标设定函数，检查是否有符合条件的对方怪兽可被破坏
function c51028231.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c51028231.desfilter(chkc) end
	-- 判断对方场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c51028231.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择一张符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c51028231.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要破坏一张对方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，对选中的目标怪兽进行破坏
function c51028231.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
