--混沌変幻
-- 效果：
-- ①：以除外的自己的光属性调整和调整以外的8星以下的暗属性怪兽各1只为对象才能发动。那2只怪兽回到墓地。那之后，把持有和回去的怪兽的等级合计相同等级的1只光·暗属性同调怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：以除外的自己的光属性调整和调整以外的8星以下的暗属性怪兽各1只为对象才能发动。那2只怪兽回到墓地。那之后，把持有和回去的怪兽的等级合计相同等级的1只光·暗属性同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤除外的自己光属性调整怪兽，且存在可配合的暗属性非调整怪兽和可特殊召唤的同调怪兽
function s.filter1(c,e,tp)
	local clv=c:GetLevel()
	return c:IsType(TYPE_TUNER) and clv>0 and c:IsAbleToGrave()
		and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 检查除外区是否存在满足条件的暗属性非调整怪兽
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_REMOVED,0,1,c,e,tp,clv)
end
-- 过滤除外的自己8星以下暗属性非调整怪兽，且额外卡组存在等级等于两者等级合计的光·暗属性同调怪兽
function s.filter2(c,e,tp,lv)
	local clv=c:GetLevel()
	return not c:IsType(TYPE_TUNER) and clv>0 and clv<=8 and c:IsAbleToGrave()
		and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查额外卡组是否存在等级等于两者等级合计的光·暗属性同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
-- 过滤额外卡组中满足等级、属性、特殊召唤条件且有可用额外怪兽区域的光·暗属性同调怪兽
function s.spfilter(c,e,tp,lv)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有可用于从额外卡组特殊召唤该怪兽的怪兽区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标选择与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查除外区是否存在符合条件的光属性调整怪兽作为发动的基本条件
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择除外的1只光属性调整怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择除外的1只8星以下暗属性非调整怪兽作为对象
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 设置将2张对象怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local tg=Duel.GetTargetsRelateToChain()
	-- 检查对象怪兽是否仍为2张，并将其作为效果/回到墓地原因送去墓地，确认是否成功送去2张
	if #tg==2 and Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)==2 then
		-- 筛选出实际成功回到墓地的怪兽
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		local lv=og:GetSum(Card.GetLevel)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只等级等于回到墓地怪兽等级合计的光·暗属性同调怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		if #sg>0 then
			-- 中断当前效果处理，使后续的特殊召唤不与回到墓地同时处理
			Duel.BreakEffect()
			-- 将选择的同调怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
