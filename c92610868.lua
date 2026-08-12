--レドレミコード・ドリーミア
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆区域有「七音服」卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己场上的「七音服」灵摆怪兽卡被对方的效果破坏的场合，可以作为那1张破坏的卡的代替而把这张卡破坏。
function c92610868.initial_effect(c)
	-- 初始化灵摆怪兽的灵摆属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c92610868.distg)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆区域有「七音服」卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92610868,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,92610868)
	e2:SetCondition(c92610868.spcon)
	e2:SetTarget(c92610868.sptg)
	e2:SetOperation(c92610868.spop)
	c:RegisterEffect(e2)
	-- ②：自己的灵摆区域有奇数的灵摆刻度存在，自己场上的「七音服」灵摆怪兽卡被对方的效果破坏的场合，可以作为那1张破坏的卡的代替而把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c92610868.repcon)
	e3:SetTarget(c92610868.reptg)
	e3:SetValue(c92610868.repval)
	c:RegisterEffect(e3)
end
-- 过滤属于自己且进行灵摆召唤的「七音服」灵摆怪兽，作为灵摆召唤不会被无效化的适用对象
function c92610868.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检测自己灵摆区域是否存在「七音服」卡，作为手卡特殊召唤效果的发动条件
function c92610868.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在至少1张「七音服」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x162)
end
-- 手卡特殊召唤效果的靶向与检测函数，检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c92610868.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己场上是否有可用的怪兽区域空格，且这张卡是否可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡特殊召唤效果的执行函数，在效果处理时将自身特殊召唤
function c92610868.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤灵摆刻度为奇数的卡
function c92610868.pfilter(c)
	return c:GetCurrentScale()%2~=0
end
-- 代替破坏效果的条件函数，检测自己的灵摆区域是否存在奇数灵摆刻度的卡
function c92610868.repcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己的灵摆区域是否存在至少1张奇数灵摆刻度的卡
	return Duel.IsExistingMatchingCard(c92610868.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 过滤符合代替破坏条件的卡：自己场上表侧表示的「七音服」灵摆怪兽，且因对方的效果而被破坏
function c92610868.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM~=0
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的靶向与检测函数，检查自身是否可被破坏，以及是否有符合条件的卡正要被破坏，并执行代替破坏的处理
function c92610868.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and eg:IsExists(c92610868.repfilter,1,c,tp) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		local sg=eg:Filter(c92610868.repfilter,c,tp)
		if sg:GetCount()>1 then
			-- 提示玩家选择要代替被破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(92610868,1))  --"请选择要代替被破坏的卡"
			sg=sg:Select(tp,1,1,nil)
		end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		-- 将这张卡作为代替而破坏
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 代替破坏效果的价值函数，用于确定被选中的卡是否在代替破坏的范围内
function c92610868.repval(e,c)
	local g=e:GetLabelObject()
	return g:IsContains(c)
end
