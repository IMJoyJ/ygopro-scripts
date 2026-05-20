--剛鬼再戦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地2只等级不同的「刚鬼」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c62376646.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地2只等级不同的「刚鬼」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62376646+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c62376646.target)
	e1:SetOperation(c62376646.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己墓地中等级大于0、可以作为效果对象且可以守备表示特殊召唤的「刚鬼」怪兽
function c62376646.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:GetLevel()>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsCanBeEffectTarget(e)
end
-- 效果发动阶段的合法性检测：检查是否满足特殊召唤2只等级不同的「刚鬼」怪兽的条件
function c62376646.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有满足特殊召唤条件的「刚鬼」怪兽
	local g=Duel.GetMatchingGroup(c62376646.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否至少有2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and g:GetClassCount(Card.GetLevel)>=2 end
	-- 设置选择特殊召唤卡片时的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择2只等级不同的怪兽
	local g1=g:SelectSubGroup(tp,aux.dlvcheck,false,2,2)
	-- 将选中的怪兽注册为当前连锁的效果对象
	Duel.SetTargetCard(g1)
	-- 设置特殊召唤2只怪兽的操作信息，用于连锁处理和应对检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理：将仍符合条件的怪兽守备表示特殊召唤到自己场上
function c62376646.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上主要怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 设置选择特殊召唤卡片时的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选定的怪兽以表侧守备表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
