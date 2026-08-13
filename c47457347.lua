--魔法名－「大いなる獣」
-- 效果：
-- ①：以除外的自己的「召唤兽」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽守备表示特殊召唤。
function c47457347.initial_effect(c)
	-- ①：以除外的自己的「召唤兽」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c47457347.target)
	e1:SetOperation(c47457347.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定对象必须表侧表示、属于「召唤兽」字段，且能够被特殊召唤为表侧守备表示。
function c47457347.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标合法性检查：对指定对象确认位于除外区、控制者为发动者且通过filter判定；发动条件为场上主要怪兽区有空位且存在至少1只满足条件的除外区的「召唤兽」怪兽。
function c47457347.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c47457347.filter(chkc,e,tp) end
	-- 发动条件检查：主要怪兽区必须存在至少1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：存在至少1只满足条件且可以成为对象的除外的自己的「召唤兽」怪兽。
		and Duel.IsExistingTarget(c47457347.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 取得发动者可用的主要怪兽区空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取除外区所有满足条件的「召唤兽」怪兽，并进一步筛选出可成为效果对象的卡。
	local g=Duel.GetMatchingGroup(c47457347.filter,tp,LOCATION_REMOVED,0,nil,e,tp):Filter(Card.IsCanBeEffectTarget,nil,e)
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选卡中任意选择1至空格数的卡片，且所选卡名互不相同（同名卡最多1张）。
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选择的卡片设为效果对象。
	Duel.SetTargetCard(tg)
	-- 登记特殊召唤的操作信息：对象为所选择的卡，数量为选择张数，以便后续处理和相关效果联动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 效果处理：根据可用怪兽区空格数与仍与效果关联的对象卡数量，将对象全部或部分表侧守备特殊召唤；若可特招数量不足，则把多余的对象卡送去墓地。
function c47457347.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动者当前可用主要怪兽区空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 取得连锁上登记的对象卡，并筛选出与本次效果仍有关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<=0 or g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将对象怪兽以表侧守备表示特殊召唤到发动者场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选出的卡片以表侧守备表示特殊召唤到发动者场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 因空格不足而未能特殊召唤的剩余对象卡，按规则送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
