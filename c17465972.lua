--BF－南風のアウステル
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤成功时，以除外的1只自己的4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●选自己场上1只「黑翼龙」放置对方场上的卡数量的黑羽指示物。
-- ●给对方场上的表侧表示怪兽全部尽可能各放置1个楔指示物（最多1个）。
function c17465972.initial_effect(c)
	-- 注册该卡为「黑翼龙」的关联卡
	aux.AddCodeList(c,9012916)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时，以除外的1只自己的4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17465972,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c17465972.sumtg)
	e2:SetOperation(c17465972.sumop)
	c:RegisterEffect(e2)
	-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。●选自己场上1只「黑翼龙」放置对方场上的卡数量的黑羽指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17465972,1))  --"「黑翼龙」放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 将此卡从墓地除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c17465972.cttg1)
	e3:SetOperation(c17465972.ctop1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(17465972,2))  --"对方全部怪兽放置指示物"
	e4:SetTarget(c17465972.cttg2)
	e4:SetOperation(c17465972.ctop2)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的除外区黑羽怪兽
function c17465972.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否能选择满足条件的除外区黑羽怪兽并检查场上是否有空位
function c17465972.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c17465972.filter(chkc,e,tp) end
	-- 检查是否存在满足条件的除外区黑羽怪兽
	if chk==0 then return Duel.IsExistingTarget(c17465972.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 检查场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外区黑羽怪兽
	local g=Duel.SelectTarget(tp,c17465972.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c17465972.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤满足条件的「黑翼龙」怪兽
function c17465972.ctfilter1(c,ct)
	return c:IsFaceup() and c:IsCode(9012916) and c:IsCanAddCounter(0x10,ct)
end
-- 判断是否能选择满足条件的「黑翼龙」怪兽并计算对方场上卡数
function c17465972.cttg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的卡数
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 检查是否存在满足条件的「黑翼龙」怪兽
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(c17465972.ctfilter1,tp,LOCATION_MZONE,0,1,nil,ct) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x10)
end
-- 执行放置指示物操作
function c17465972.ctop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡数
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 选择满足条件的「黑翼龙」怪兽
		local g=Duel.SelectMatchingCard(tp,c17465972.ctfilter1,tp,LOCATION_MZONE,0,1,1,nil,ct)
		local tc=g:GetFirst()
		if tc then
			tc:AddCounter(0x10,ct)
		end
	end
end
-- 过滤满足条件的对方场上怪兽
function c17465972.ctfilter2(c)
	return c:IsFaceup() and c:GetCounter(0x1002)==0 and c:IsCanAddCounter(0x1002,1)
end
-- 判断是否能选择满足条件的对方场上怪兽
function c17465972.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的对方场上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17465972.ctfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1002)
end
-- 执行放置指示物操作
function c17465972.ctop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的对方场上怪兽组
	local g=Duel.GetMatchingGroup(c17465972.ctfilter2,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1002,1)
		tc=g:GetNext()
	end
end
