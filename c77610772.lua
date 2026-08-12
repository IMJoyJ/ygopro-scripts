--星杯神楽イヴ
-- 效果：
-- 种族和属性不同的怪兽2只
-- ①：连接状态的这张卡不会被战斗·效果破坏，不会成为对方的效果的对象。
-- ②：这张卡所连接区的怪兽被效果破坏的场合，可以作为代替把这张卡送去墓地。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
function c77610772.initial_effect(c)
	-- 为卡片添加连接召唤手续，需要2只种族和属性不同的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2,c77610772.lcheck)
	c:EnableReviveLimit()
	-- ①：连接状态的这张卡不会被战斗·效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c77610772.incon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为对方的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：这张卡所连接区的怪兽被效果破坏的场合，可以作为代替把这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c77610772.reptg)
	e4:SetValue(c77610772.repval)
	e4:SetOperation(c77610772.repop)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只「星杯」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(77610772,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c77610772.spcon2)
	e5:SetTarget(c77610772.sptg2)
	e5:SetOperation(c77610772.spop2)
	c:RegisterEffect(e5)
end
-- 过滤函数：检查作为连接素材的怪兽是否种族和属性各不相同
function c77610772.lcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount() and g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
-- 条件函数：这张卡处于连接状态
function c77610772.incon(e)
	return e:GetHandler():IsLinkState()
end
-- 过滤函数：检查是否为自己场上因效果破坏且处于这张卡所连接区的表侧表示怪兽
function c77610772.repfilter(c,tp,hc)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and hc:GetLinkedGroup():IsContains(c)
end
-- 目标过滤函数：检查自身是否未确定被破坏，且是否存在满足代替条件的被破坏怪兽
function c77610772.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c77610772.repfilter,1,nil,tp,e:GetHandler()) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 价值函数：确定哪些怪兽被破坏时可以应用此代替效果
function c77610772.repval(e,c)
	return c77610772.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end
-- 操作函数：将自身送去墓地以代替破坏
function c77610772.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 条件函数：这张卡从场上送去墓地
function c77610772.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：检查手卡中是否存在可以特殊召唤的「星杯」怪兽
function c77610772.spfilter2(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标过滤函数：检查自己场上是否有空怪兽位，且手卡中是否存在可特殊召唤的「星杯」怪兽
function c77610772.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的「星杯」怪兽
		and Duel.IsExistingMatchingCard(c77610772.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 操作函数：从手卡选择1只「星杯」怪兽特殊召唤
function c77610772.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「星杯」怪兽
	local g=Duel.SelectMatchingCard(tp,c77610772.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
