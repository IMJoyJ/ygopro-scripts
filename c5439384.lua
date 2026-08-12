--炎雄爆誕
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的守备力200的炎属性怪兽之中以调整1只和调整以外的怪兽1只为对象才能发动。那2只怪兽除外，把持有和那个等级合计相同等级的1只炎属性同调怪兽从额外卡组特殊召唤。
function c5439384.initial_effect(c)
	-- ①：从自己墓地的守备力200的炎属性怪兽之中以调整1只和调整以外的怪兽1只为对象才能发动。那2只怪兽除外，把持有和那个等级合计相同等级的1只炎属性同调怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,5439384+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c5439384.target)
	e1:SetOperation(c5439384.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中满足条件的炎属性、守备力200的调整怪兽
function c5439384.filter1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDefense(200) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		-- 检查自己墓地是否存在可与该调整怪兽配合的非调整怪兽
		and Duel.IsExistingTarget(c5439384.filter2,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetLevel())
end
-- 过滤自己墓地中满足条件的炎属性、守备力200的非调整怪兽
function c5439384.filter2(c,e,tp,lv)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDefense(200) and not c:IsType(TYPE_TUNER) and c:IsLevelAbove(0) and c:IsAbleToRemove()
		-- 检查额外卡组是否存在等级等于两只怪兽等级合计的炎属性同调怪兽
		and Duel.IsExistingMatchingCard(c5439384.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()+lv)
end
-- 过滤额外卡组中满足等级、属性、类型条件且可以特殊召唤的同调怪兽
function c5439384.spfilter(c,e,tp,lv)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv)
		-- 检查额外怪兽区域或可用的主怪兽区域是否有空位，并确认该同调怪兽是否能特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数
function c5439384.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在符合条件的调整怪兽作为发动的基本条件
	if chk==0 then return Duel.IsExistingTarget(c5439384.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只满足条件的调整怪兽作为对象
	local g1=Duel.SelectTarget(tp,c5439384.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只满足条件的非调整怪兽作为对象（排除已选择的调整怪兽）
	local g2=Duel.SelectTarget(tp,c5439384.filter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 设置连锁信息，表示该效果包含将选中的2只怪兽除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
	-- 设置连锁信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（发动）函数
function c5439384.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=2 then return end
	-- 将作为对象的2只怪兽表侧表示除外，并确认是否成功除外了2只
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==2 then
		-- 获取刚才因效果实际被除外的卡片组
		local og=Duel.GetOperatedGroup()
		local lv=og:GetSum(Card.GetLevel)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只等级等于被除外怪兽等级合计的炎属性同调怪兽
		local sg=Duel.SelectMatchingCard(tp,c5439384.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		if #sg>0 then
			-- 将选中的同调怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
