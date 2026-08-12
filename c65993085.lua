--やりすぎた埋葬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡丢弃1只怪兽，以原本等级比丢弃的怪兽低的自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
-- ②：装备怪兽的效果无效化。
function c65993085.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡丢弃1只怪兽，以原本等级比丢弃的怪兽低的自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65993085+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c65993085.cost)
	e1:SetTarget(c65993085.target)
	e1:SetOperation(c65993085.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
end
-- 在发动代价检测中设置标记，用于在target中区分检测与实际发动
function c65993085.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤手牌中原本等级大于1、可以丢弃的怪兽，且自己墓地存在原本等级比其低的、可作为效果对象的怪兽
function c65993085.costfilter(c,e,tp)
	local lv=c:GetOriginalLevel()
	return lv>1 and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
		-- 检查自己墓地是否存在至少1只原本等级低于丢弃怪兽且可以特殊召唤的对象
		and Duel.IsExistingTarget(c65993085.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
-- 过滤墓地中原本等级低于指定数值且可以特殊召唤的怪兽
function c65993085.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与代价处理：丢弃1只手牌怪兽，并选择自己墓地1只原本等级比其低的怪兽为对象
function c65993085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65993085.spfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否有可用于特殊召唤怪兽的空余怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手牌中是否存在满足丢弃条件且墓地有对应可召唤对象的怪兽
			and Duel.IsExistingMatchingCard(c65993085.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 给玩家发送提示信息：请选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1张满足条件的手牌怪兽作为发动代价丢弃
	local cg=Duel.SelectMatchingCard(tp,c65993085.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的手牌怪兽作为发动的代价丢弃送去墓地
	Duel.SendtoGrave(cg,REASON_DISCARD+REASON_COST)
	local lv=cg:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只原本等级低于丢弃怪兽的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c65993085.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置连锁信息：包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息：包含将这张卡装备给特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将作为对象的墓地怪兽特殊召唤，并将这张卡装备给那只怪兽
function c65993085.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽在自己场上表侧表示特殊召唤，并判断是否特殊召唤成功
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 将这张卡作为装备卡装备给特殊召唤的怪兽
			Duel.Equip(tp,c,tc)
			-- 把这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c65993085.eqlimit)
			e1:SetLabelObject(tc)
			c:RegisterEffect(e1)
		end
	end
end
-- 装备限制：这张卡只能装备给通过这个效果特殊召唤的怪兽
function c65993085.eqlimit(e,c)
	return e:GetLabelObject()==c
end
