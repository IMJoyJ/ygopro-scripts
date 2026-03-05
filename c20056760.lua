--グレイドル・スライム
-- 效果：
-- 「灰篮史莱姆」的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上2张「灰篮」卡为对象才能发动。那些卡破坏，这张卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功时，以自己墓地1只「灰篮」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c20056760.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上2张「灰篮」卡为对象才能发动。那些卡破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,20056760)
	e1:SetTarget(c20056760.sptg1)
	e1:SetOperation(c20056760.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功时，以自己墓地1只「灰篮」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c20056760.spcon2)
	e2:SetTarget(c20056760.sptg2)
	e2:SetOperation(c20056760.spop2)
	c:RegisterEffect(e2)
end
-- 用于判断场上是否存在「灰篮」卡
function c20056760.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd1)
end
-- 效果处理时判断是否满足发动条件并选择对象
function c20056760.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c20056760.filter(chkc) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if ft<-1 then return false end
		return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断场上是否存在2张以上「灰篮」卡
			and Duel.IsExistingTarget(c20056760.filter,tp,LOCATION_ONFIELD,0,2,nil)
			-- 判断是否满足破坏2张卡的条件
			and (ft>0 or Duel.IsExistingTarget(c20056760.filter,tp,LOCATION_MZONE,0,-ft+1,nil))
	end
	local g=nil
	if ft~=0 then
		local loc=LOCATION_ONFIELD
		if ft<0 then loc=LOCATION_MZONE end
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的2张「灰篮」卡
		g=Duel.SelectTarget(tp,c20056760.filter,tp,loc,0,2,2,nil)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的1张「灰篮」卡
		g=Duel.SelectTarget(tp,c20056760.filter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的1张「灰篮」卡
		local g2=Duel.SelectTarget(tp,c20056760.filter,tp,LOCATION_ONFIELD,0,1,1,g:GetFirst())
		g:Merge(g2)
	end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时执行破坏和特殊召唤
function c20056760.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 执行破坏操作
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为通过①效果特殊召唤成功
function c20056760.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 用于判断墓地是否存在可特殊召唤的「灰篮」怪兽
function c20056760.spfilter(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理时判断是否满足发动条件并选择对象
function c20056760.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20056760.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在「灰篮」怪兽
		and Duel.IsExistingTarget(c20056760.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的「灰篮」怪兽
	local g=Duel.SelectTarget(tp,c20056760.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时执行特殊召唤
function c20056760.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
