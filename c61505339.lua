--創世神
-- 效果：
-- 选择自己墓地的1张怪兽卡。将1张手卡送去墓地，选择的那张怪兽卡特殊召唤。这个效果1个回合只能使用1次。这张卡不能从墓地特殊召唤。
function c61505339.initial_effect(c)
	-- 这张卡不能从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 选择自己墓地的1张怪兽卡。将1张手卡送去墓地，选择的那张怪兽卡特殊召唤。这个效果1个回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61505339,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c61505339.sptg)
	e2:SetOperation(c61505339.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：可以特殊召唤的怪兽
function c61505339.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测
function c61505339.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61505339.filter(chkc,e,tp) end
	-- 检查自身怪兽区域是否有空位，且手牌数量是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查自己墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c61505339.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1张可以特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61505339.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将手牌中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将选择的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c61505339.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查手牌数量，若无手牌则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=0 then return end
	-- 提示玩家选择要送去墓地的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手牌送去墓地
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	if sg:GetCount()==0 then return end
	-- 将选择的手牌送去墓地，若未成功送去墓地则流程终止
	if Duel.SendtoGrave(sg,REASON_EFFECT)==0 or not sg:GetFirst():IsLocation(LOCATION_GRAVE) then return end
	-- 获取发动的效果对象（即墓地中选择的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
