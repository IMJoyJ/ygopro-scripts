--時空超越
-- 效果：
-- ①：从自己墓地把恐龙族怪兽2只以上除外才能发动。从自己的手卡·墓地选持有和除外的怪兽的等级合计相同等级的1只恐龙族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c39041729.initial_effect(c)
	-- ①：从自己墓地把恐龙族怪兽2只以上除外才能发动。从自己的手卡·墓地选持有和除外的怪兽的等级合计相同等级的1只恐龙族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c39041729.cost)
	e1:SetTarget(c39041729.target)
	e1:SetOperation(c39041729.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的怪兽：等级大于0、恐龙族、可以特殊召唤、并且其墓地的恐龙族怪兽数量和大于等于该怪兽等级
function c39041729.filter(c,e,tp)
	-- 获取满足条件的墓地恐龙族怪兽组
	local rg=Duel.GetMatchingGroup(c39041729.cfilter,tp,LOCATION_GRAVE,0,c)
	local lv=c:GetLevel()
	return lv>0 and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and rg:CheckWithSumEqual(Card.GetLevel,lv,2,99)
end
-- 过滤满足条件的墓地恐龙族怪兽：恐龙族、可以除外作为费用
function c39041729.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 设置效果标签为100，表示已支付费用
function c39041729.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 判断是否满足发动条件：效果标签为100、场上存在空位、手牌或墓地存在满足条件的怪兽
function c39041729.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 判断场上是否存在空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断手牌或墓地是否存在满足条件的怪兽
			and Duel.IsExistingMatchingCard(c39041729.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c39041729.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	local lvt={}
	local pc=1
	for i=2,12 do
		if g:IsExists(c39041729.spfilter,1,nil,e,tp,i) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要特殊召唤的怪兽等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39041729,0))  --"请选择要特殊召唤的怪兽的等级"
	-- 玩家宣言要特殊召唤的怪兽等级
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 获取满足条件的墓地恐龙族怪兽组
	local rg=Duel.GetMatchingGroup(c39041729.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectWithSumEqual(tp,Card.GetLevel,lv,2,99)
	-- 将选中的卡除外作为费用
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 过滤满足条件的怪兽：等级等于指定等级、恐龙族、可以特殊召唤
function c39041729.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断场上是否存在空位，若无则返回；提示玩家选择要特殊召唤的卡；特殊召唤选中的卡；给该怪兽添加不能攻击的效果
function c39041729.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39041729.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,e:GetLabel())
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
