--グレイドル・スライム
-- 效果：
-- 「灰篮史莱姆」的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上2张「灰篮」卡为对象才能发动。那些卡破坏，这张卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功时，以自己墓地1只「灰篮」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c20056760.initial_effect(c)
	-- 对应：“「灰篮史莱姆」的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，以自己场上2张「灰篮」卡为对象才能发动。那些卡破坏，这张卡特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,20056760)
	e1:SetTarget(c20056760.sptg1)
	e1:SetOperation(c20056760.spop1)
	c:RegisterEffect(e1)
	-- 对应：“②：这张卡的①的效果特殊召唤成功时，以自己墓地1只「灰篮」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。”
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
-- 过滤函数：判断卡片是否为表侧表示且拥有「灰篮」字段。
function c20056760.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd1)
end
-- ①效果的发动条件判定与目标选择：要求此卡可特殊召唤、场上存在2张表侧「灰篮」卡可供破坏，并根据可用怪兽区格数分情况选择2张对象；同时设置破坏与特殊召唤的操作信息。
function c20056760.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c20056760.filter(chkc) end
	-- 计算我方主要怪兽区的可用空格数，用于判断破坏2张卡后是否仍有格子特殊召唤此卡。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if ft<-1 then return false end
		return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 确认场上是否存在至少2张可被取对象的表侧「灰篮」卡。
			and Duel.IsExistingTarget(c20056760.filter,tp,LOCATION_ONFIELD,0,2,nil)
			-- 当可用怪兽区空格数不足时，额外确认可以选择足够数量的主要怪兽区的「灰篮」卡作为对象，以便破坏后腾出特殊召唤所需空格。
			and (ft>0 or Duel.IsExistingTarget(c20056760.filter,tp,LOCATION_MZONE,0,-ft+1,nil))
	end
	local g=nil
	if ft~=0 then
		local loc=LOCATION_ONFIELD
		if ft<0 then loc=LOCATION_MZONE end
		-- 给玩家发送提示，要求选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从指定区域（空格数大于0时为场上，小于0时为主要怪兽区）选择2张表侧「灰篮」卡作为效果对象。
		g=Duel.SelectTarget(tp,c20056760.filter,tp,loc,0,2,2,nil)
	else
		-- 给玩家发送提示，要求选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 在主要怪兽区选择1张表侧「灰篮」卡作为对象（用于可用怪兽区空格为0时）。
		g=Duel.SelectTarget(tp,c20056760.filter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 给玩家发送提示，要求选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 在场上选择另一张表侧「灰篮」卡作为对象（排除已选的那张），凑齐2张对象。
		local g2=Duel.SelectTarget(tp,c20056760.filter,tp,LOCATION_ONFIELD,0,1,1,g:GetFirst())
		g:Merge(g2)
	end
	-- 设置破坏的操作信息：将已选择的2张卡作为破坏对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置特殊召唤的操作信息：本卡将在效果处理时特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果：取连锁对象中仍与效果关联的卡并将其破坏；若破坏成功且此卡仍与效果关联，则将此卡特殊召唤。
function c20056760.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组，并筛选出仍然与本次效果关联的卡（未被离场或无效等原因取消联系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果破坏筛选出的对象卡，若实际破坏了至少1张则继续后续特殊召唤处理。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将此卡以正面表示特殊召唤到其控制者场上，并标记召唤方式为SUMMON_VALUE_SELF，供②效果识别。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：判断此卡是否通过①效果（即召唤方式为SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）特殊召唤成功。
function c20056760.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数：检查墓地中的卡是否为「灰篮」怪兽，且能够以表侧守备表示特殊召唤。
function c20056760.spfilter(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动判定与目标选择：确认我方主要怪兽区有空位且墓地存在符合条件的「灰篮」怪兽，选择1只为对象并设置特殊召唤操作信息。
function c20056760.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20056760.spfilter(chkc,e,tp) end
	-- 发动时（chk==0）确认我方主要怪兽区是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地存在至少1只可被取对象且满足特殊召唤条件的「灰篮」怪兽。
		and Duel.IsExistingTarget(c20056760.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只满足条件的「灰篮」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c20056760.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息：将选择的墓地怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果：将对象怪兽以表侧守备表示特殊召唤。
function c20056760.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的第一个（也是唯一一个）对象卡，即选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到其控制者的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
