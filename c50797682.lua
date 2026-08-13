--先史遺産石紋
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，以自己的场上·墓地1张超量怪兽卡为对象才能发动。从自己的手卡·卡组·墓地选持有比那张怪兽卡的阶级数值高1的等级的2只「先史遗产」怪兽效果无效特殊召唤，只用那2只为素材把1只「先史遗产」超量怪兽超量召唤。
function c50797682.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，以自己的场上·墓地1张超量怪兽卡为对象才能发动。从自己的手卡·卡组·墓地选持有比那张怪兽卡的阶级数值高1的等级的2只「先史遗产」怪兽效果无效特殊召唤，只用那2只为素材把1只「先史遗产」超量怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,50797682+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c50797682.condition)
	e1:SetTarget(c50797682.target)
	e1:SetOperation(c50797682.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：仅在自己·对方的主要阶段（主要阶段1或主要阶段2）才能发动。
function c50797682.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否满足发动条件。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 对象选择过滤：对象必须是我方场上或墓地的表侧超量怪兽卡，且存在可用的素材和可超量召唤的「先史遗产」超量怪兽。
function c50797682.tgfilter(c,e,tp)
	if c:GetOriginalType()&TYPE_XYZ==0 or c:IsFacedown() then return false end
	-- 从手卡·卡组·墓地中筛选出等级等于对象阶级+1、属于「先史遗产」且可特殊召唤的怪兽群，作为候选素材。
	local mg=Duel.GetMatchingGroup(c50797682.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,c:GetRank())
	-- 检查额外卡组中是否存在能用这些候选素材进行超量召唤的「先史遗产」超量怪兽，以确认该对象合法。
	return Duel.IsExistingMatchingCard(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
end
-- 素材过滤：怪兽的等级必须等于对象超量怪兽的阶级+1，属于「先史遗产」字段，并且可以通过效果特殊召唤。
function c50797682.spfilter(c,e,tp,rk)
	return c:IsLevel(rk+1) and c:IsSetCard(0x70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 超量怪兽过滤：属于「先史遗产」字段，可以用2只素材进行超量召唤，并且可以因此效果特殊召唤。
function c50797682.xyzfilter(c,e,tp,mg)
	return c:IsSetCard(0x70) and c:IsXyzSummonable(mg,2,2) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
-- 选择第1只素材时，要求素材组中存在另一只素材能与它组成超量召唤素材组合。
function c50797682.mfilter1(c,mg,exg)
	return mg:IsExists(c50797682.mfilter2,1,c,c,exg)
end
-- 选择第2只素材时，要求它与已选的第1只素材一起能够满足超量召唤条件。
function c50797682.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- 发动时进行目标选择与合法性判定：需要选择1张我方场上或墓地的超量怪兽卡作为对象，并确认特殊召唤的可行条件。
function c50797682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c50797682.tgfilter(chkc,e,tp) end
	-- 发动合法性检查：当前玩家至少还能进行2次特殊召唤（因为要特殊召唤2只素材怪兽）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 发动合法性检查：我方主要怪兽区至少要有2个空格，用于放置特殊召唤的素材怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 发动合法性检查：场上或墓地存在1张符合条件的超量怪兽卡可以作为对象。
		and Duel.IsExistingTarget(c50797682.tgfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象（超量怪兽卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从我方场上或墓地选择1张符合条件的超量怪兽卡作为效果对象。
	Duel.SelectTarget(tp,c50797682.tgfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将从手卡·卡组·墓地特殊召唤2只怪兽（分类为特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：特殊召唤2只符合条件的「先史遗产」怪兽，将它们效果无效化，并用它们作为超量素材进行「先史遗产」超量怪兽的超量召唤。
function c50797682.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前检查：若当前玩家本回合剩余可特殊召唤次数不足2次，则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理前检查：若我方主要怪兽区可用空格不足2格，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 取得发动时选择的对象超量怪兽卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 从手卡·卡组·墓地中取得符合条件的素材怪兽群（过滤王家长眠之谷影响），等级为对象阶级+1且属于「先史遗产」。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50797682.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,tc:GetRank())
	-- 从额外卡组中取得能用这些素材进行超量召唤的「先史遗产」超量怪兽群。
	local exg=Duel.GetMatchingGroup(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	-- 提示玩家选择第1只要特殊召唤的素材怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g1=mg:FilterSelect(tp,c50797682.mfilter1,1,1,nil,mg,exg)
	local tc1=g1:GetFirst()
	-- 提示玩家选择第2只要特殊召唤的素材怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g2=mg:FilterSelect(tp,c50797682.mfilter2,1,1,tc1,tc1,exg)
	g1:Merge(g2)
	if g1:GetCount()<2 then return end
	local tc=g1:GetFirst()
	while tc do
		-- 将选出的素材怪兽以表侧攻击表示逐只加入特殊召唤流程（尚未完成特殊召唤）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g1:GetNext()
	end
	-- 完成整个特殊召唤流程，正式特殊召唤所有素材怪兽。
	Duel.SpecialSummonComplete()
	-- 立即刷新场地状态，确保后续判断使用最新信息。
	Duel.AdjustAll()
	if g1:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 重新从额外卡组中取得可用当前素材进行超量召唤的「先史遗产」超量怪兽。
	local xyzg=Duel.GetMatchingGroup(c50797682.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,g1)
	if #xyzg>0 then
		-- 提示玩家选择要超量召唤的「先史遗产」超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 用已特殊召唤的2只素材怪兽作为超量素材，进行「先史遗产」超量怪兽的超量召唤。
		Duel.XyzSummon(tp,xyz,g1)
	end
end
