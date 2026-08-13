--絆醒師セームベル
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有和这张卡相同等级的灵摆怪兽卡存在的场合才能发动。另一边的自己的灵摆区域的卡破坏，这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，自己场上有其他怪兽特殊召唤的场合才能发动。和这张卡相同等级的1只怪兽从手卡特殊召唤。
function c46999905.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其能够在灵摆区域放置、进行灵摆召唤以及发动灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果原文：①：另一边的自己的灵摆区域有和这张卡相同等级的灵摆怪兽卡存在的场合才能发动。另一边的自己的灵摆区域的卡破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46999905,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,46999905)
	e1:SetCondition(c46999905.spcon)
	e1:SetTarget(c46999905.sptg)
	e1:SetOperation(c46999905.spop)
	c:RegisterEffect(e1)
	-- 对应怪兽效果原文：①：这张卡已在怪兽区域存在的状态，自己场上有其他怪兽特殊召唤的场合才能发动。和这张卡相同等级的1只怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46999905,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46999906)
	e2:SetCondition(c46999905.spcon2)
	e2:SetTarget(c46999905.sptg2)
	e2:SetOperation(c46999905.spop2)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：判断用于比较的卡是否与指定怪兽等级相同。
function c46999905.filter(c,mc)
	return c:IsLevel(mc:GetLevel())
end
-- 灵摆效果的发动条件判定：检查己方灵摆区域是否存在另一张等级与此卡相同的灵摆怪兽卡。
function c46999905.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方灵摆区域检查是否存在至少1张满足c46999905.filter条件且不是此卡自身的灵摆怪兽卡。
	return Duel.IsExistingMatchingCard(c46999905.filter,tp,LOCATION_PZONE,0,1,e:GetHandler(),e:GetHandler())
end
-- 灵摆效果的发动目标与操作信息设定：确认此卡可以特殊召唤且主怪兽区有空位，并预先记录要破坏的另一侧灵摆卡和特殊召唤此卡。
function c46999905.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查：己方主怪兽区是否有可用空格，且此卡是否能够被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 获取己方灵摆区域中除自身外的另一张卡（即另一边的灵摆区域的卡），作为要破坏的对象。
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 设定操作信息：登记要破坏的对象tc，数量为1，用于后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设定操作信息：登记要特殊召唤的对象为此卡c，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果的处理：先取另一边的灵摆区域的卡，若存在则将其破坏，破坏成功后再将此卡特殊召唤。
function c46999905.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次获取另一边的灵摆区域的卡作为破坏对象。
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 若存在该卡且被效果成功破坏（Duel.Destroy返回值不为0），则执行后续特殊召唤。
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 将此卡以表侧表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义筛选函数：判断怪兽控制者是否为tp。
function c46999905.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 怪兽效果的发动条件判定：特殊召唤的怪兽集合中不含此卡自身，且存在至少1只为己方控制的其他怪兽。
function c46999905.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c46999905.cfilter,1,nil,tp)
end
-- 定义手卡筛选函数：选择等级与此卡相同且可以被特殊召唤的怪兽。
function c46999905.spfilter2(c,e,tp,tc)
	return c:IsLevel(tc:GetLevel()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果的发动目标与操作信息设定：确认主怪兽区有空位，且手牌中存在可特殊召唤的同等级怪兽。
function c46999905.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查：己方主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足等级相同且可特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c46999905.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,c) end
	-- 设定操作信息：登记特殊召唤操作（处理时再从手卡选择1只）数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 怪兽效果的处理：确认此卡仍在场且表侧表示，主怪兽区有空位后，从手卡选择1只同等级怪兽特殊召唤。
function c46999905.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	-- 若主怪兽区没有空位，则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出选择要特殊召唤的怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足spfilter2条件的怪兽（等级相同且可特殊召唤）作为特殊召唤对象。
	local sg=Duel.SelectMatchingCard(tp,c46999905.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,c)
	if sg:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方主要怪兽区。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
