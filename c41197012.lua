--スカーレッド・カーペット
-- 效果：
-- ①：场上有龙族同调怪兽存在的场合，以自己墓地最多2只「共鸣者」怪兽为对象才能发动。那些怪兽特殊召唤。
function c41197012.initial_effect(c)
	-- 效果原文内容：①：场上有龙族同调怪兽存在的场合，以自己墓地最多2只「共鸣者」怪兽为对象才能发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c41197012.spcon)
	e1:SetTarget(c41197012.sptg)
	e1:SetOperation(c41197012.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在龙族同调怪兽
function c41197012.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 效果作用：检查场上是否存在龙族同调怪兽
function c41197012.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否存在龙族同调怪兽
	return Duel.IsExistingMatchingCard(c41197012.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果作用：过滤「共鸣者」怪兽且可以特殊召唤
function c41197012.filter(c,e,tp)
	return c:IsSetCard(0x57) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果目标为己方墓地的「共鸣者」怪兽
function c41197012.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c41197012.filter(chkc,e,tp) end
	-- 效果作用：判断是否满足发动条件，检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断是否满足发动条件，检查己方墓地是否存在「共鸣者」怪兽
		and Duel.IsExistingTarget(c41197012.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：获取己方场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c41197012.filter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 效果作用：设置连锁操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果原文内容：①：场上有龙族同调怪兽存在的场合，以自己墓地最多2只「共鸣者」怪兽为对象才能发动。那些怪兽特殊召唤。
function c41197012.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 效果作用：获取连锁中设定的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft>=g:GetCount() then
		-- 效果作用：将符合条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg2=sg:Select(tp,ft,ft,nil)
		-- 效果作用：将符合条件的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
	end
end
