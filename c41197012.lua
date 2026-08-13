--スカーレッド・カーペット
-- 效果：
-- ①：场上有龙族同调怪兽存在的场合，以自己墓地最多2只「共鸣者」怪兽为对象才能发动。那些怪兽特殊召唤。
function c41197012.initial_effect(c)
	-- ①：场上有龙族同调怪兽存在的场合，以自己墓地最多2只「共鸣者」怪兽为对象才能发动。那些怪兽特殊召唤。
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
-- 过滤函数：判断怪兽是否为表侧表示的龙族同调怪兽，用于检查场上是否满足发动条件。
function c41197012.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 效果发动条件函数：检查双方主要怪兽区域是否存在至少1只表侧表示的龙族同调怪兽，满足时才能发动。
function c41197012.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方主要怪兽区域是否存在至少1张满足cfilter条件的表侧表示龙族同调怪兽，作为发动条件判断。
	return Duel.IsExistingMatchingCard(c41197012.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤函数：筛选墓地中属于「共鸣者」字段、且可被本次效果特殊召唤的怪兽（需满足召唤条件与苏生限制）。
function c41197012.filter(c,e,tp)
	return c:IsSetCard(0x57) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标设定流程：确认己方主要怪兽区域有空位且墓地存在至少1只可特殊召唤的「共鸣者」怪兽；若指定对象则校验该对象是否为自己墓地的合法「共鸣者」怪兽。
function c41197012.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c41197012.filter(chkc,e,tp) end
	-- 发动时确认自己场上主要怪兽区域存在可用空格，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只满足条件的「共鸣者」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c41197012.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取自己场上主要怪兽区域当前可用空格数，用于确定最多可选对象数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的「共鸣者」怪兽中选择1～ct张（ct为可用区域数，上限2）作为效果对象。
	local g=Duel.SelectTarget(tp,c41197012.filter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 将本次操作信息登记为“特殊召唤”，对象为已选择的目标卡组，数量为选择张数。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理函数：确认仍有可用区域，取得连锁对象并筛选仍与效果关联的卡；若「青眼精灵龙」效果适用中则不能同时特殊召唤2只以上；可用区域充足时全部特殊召唤，不足时由玩家选择可容纳数量进行特殊召唤。
function c41197012.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区域当前可用空格数，用于决定实际特殊召唤数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从当前连锁信息中取出发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft>=g:GetCount() then
		-- 将仍与效果关联的「共鸣者」怪兽全部以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg2=sg:Select(tp,ft,ft,nil)
		-- 将玩家选出的「共鸣者」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
	end
end
