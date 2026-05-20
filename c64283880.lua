--ガードゴー！
-- 效果：
-- ①：自己场上的「我我我」、「怒怒怒」、「隆隆隆」怪兽的其中任意种被战斗·效果破坏送去墓地的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从手卡把「我我我」、「怒怒怒」、「隆隆隆」怪兽合计最多2只守备表示特殊召唤。
function c64283880.initial_effect(c)
	-- ①：自己场上的「我我我」、「怒怒怒」、「隆隆隆」怪兽的其中任意种被战斗·效果破坏送去墓地的场合，以那1只怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从手卡把「我我我」、「怒怒怒」、「隆隆隆」怪兽合计最多2只守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c64283880.sptg)
	e1:SetOperation(c64283880.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上因战斗或效果破坏送去墓地的「我我我」、「怒怒怒」、「隆隆隆」怪兽
function c64283880.filter(c,e,tp)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsSetCard(0x54,0x82,0x59)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与检测
function c64283880.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c64283880.filter(chkc,e,tp) end
	-- 检测自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c64283880.filter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c64283880.filter,1,1,nil,e,tp)
	-- 将选中的怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置特殊召唤1只怪兽的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤手牌中可以守备表示特殊召唤的「我我我」、「怒怒怒」、「隆隆隆」怪兽
function c64283880.spfilter(c,e,tp)
	return c:IsSetCard(0x54,0x82,0x59) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理，先特殊召唤对象怪兽，成功后再决定是否从手牌特殊召唤最多2只怪兽
function c64283880.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其表侧表示特殊召唤，并确认是否成功
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己场上可用的怪兽区域空格数
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct<=0 then return end
		-- 获取手牌中满足特殊召唤条件的怪兽组
		local g=Duel.GetMatchingGroup(c64283880.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若手牌有符合条件的怪兽，询问玩家是否进行后续的特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(64283880,0)) then  --"是否从手卡把怪兽特殊召唤？"
			-- 中断效果处理，使前后的特殊召唤不视为同时进行
			Duel.BreakEffect()
			if ct>2 then ct=2 end
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 提示玩家选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,ct,nil)
			-- 将选中的手牌怪兽以表侧守备表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
