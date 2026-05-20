--ライバル登場！
-- 效果：
-- 选择对方场上表侧表示存在的1只怪兽。从手卡特殊召唤1只和选择怪兽等级一样的怪兽。
function c5728014.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只怪兽。从手卡特殊召唤1只和选择怪兽等级一样的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5728014.target)
	e1:SetOperation(c5728014.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示、等级大于0，且手卡存在与之等级相同并能特殊召唤的怪兽的过滤函数
function c5728014.filter(c,e,tp)
	local lv=c:GetLevel()
	-- 检查卡片是否表侧表示、等级大于0，且手卡中存在至少1只等级相同且可以特殊召唤的怪兽
	return c:IsFaceup() and lv>0 and Duel.IsExistingMatchingCard(c5728014.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lv)
end
-- 过滤手卡中等级与目标怪兽相同且可以特殊召唤的怪兽的过滤函数
function c5728014.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查函数
function c5728014.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只满足条件的可选择为对象的怪兽
		and Duel.IsExistingTarget(c5728014.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择对方的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果的对象
	Duel.SelectTarget(tp,c5728014.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理（特殊召唤）的执行函数
function c5728014.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只与对象怪兽等级相同的怪兽
		local g=Duel.SelectMatchingCard(tp,c5728014.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自身场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
