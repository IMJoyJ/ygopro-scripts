--紅蓮魔闘士
-- 效果：
-- ①：这张卡可以在自己墓地的通常怪兽是3只的场合，把那之内的2只除外，从手卡特殊召唤。
-- ②：1回合1次，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c46237548.initial_effect(c)
	-- ①：这张卡可以在自己墓地的通常怪兽是3只的场合，把那之内的2只除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c46237548.spcon)
	e1:SetTarget(c46237548.sptg)
	e1:SetOperation(c46237548.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46237548,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c46237548.target)
	e2:SetOperation(c46237548.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的通常怪兽（可除外作为费用）
function c46237548.spcfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件：场上存在空位、墓地有3只通常怪兽、墓地有2张以上可除外的通常怪兽
function c46237548.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己墓地通常怪兽数量是否为3
		and Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_NORMAL)==3
		-- 判断自己墓地是否存在至少2张满足条件的通常怪兽
		and Duel.IsExistingMatchingCard(c46237548.spcfilter,c:GetControler(),LOCATION_GRAVE,0,2,nil)
end
-- 设置特殊召唤时的选择处理函数：从墓地中选择2张通常怪兽除外
function c46237548.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有可除外的通常怪兽组
	local g=Duel.GetMatchingGroup(c46237548.spcfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 设置特殊召唤时的执行处理函数：将选中的卡除外
function c46237548.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡除外（REASON_SPSUMMON）
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于检索满足条件的可特殊召唤的通常怪兽（4星以下）
function c46237548.tgfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果选择目标函数：选择墓地1只4星以下的通常怪兽作为对象
function c46237548.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46237548.tgfilter(chkc,e,tp) end
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在至少1张满足条件的通常怪兽
		and Duel.IsExistingTarget(c46237548.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从墓地中选择1只4星以下的通常怪兽
	local g=Duel.SelectTarget(tp,c46237548.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置效果执行处理函数：将选中的卡特殊召唤
function c46237548.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
