--宝玉の祝福
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：选自己的魔法与陷阱区域最多2张「宝玉兽」怪兽卡特殊召唤，自己基本分回复那个原本攻击力合计的数值。
-- ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。自己卡组最上面的卡翻开，那是「宝玉兽」怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（发动从己方魔陷区特召最多2张「宝玉兽」怪兽卡并回复其原本攻击力合计的基本分）与②效果（墓地除外，在魔陷区放置「宝玉兽」卡时翻开卡组顶，为「宝玉兽」怪兽则加手或特召，否则送墓）
function s.initial_effect(c)
	-- ①：选自己的魔法与陷阱区域最多2张「宝玉兽」怪兽卡特殊召唤，自己基本分回复那个原本攻击力合计的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。 ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。自己卡组最上面的卡翻开，那是「宝玉兽」怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.flipcon)
	-- 设置②效果的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fliptg)
	e2:SetOperation(s.flipop)
	c:RegisterEffect(e2)
end
-- 筛选条件：检查己方魔法与陷阱区域（序号小于5）的表侧卡片是否为原本类型为怪兽的「宝玉兽」卡，且可以被特殊召唤
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetSequence()<5
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检测：确认己方怪兽区有空位，且己方魔陷区存在满足条件的「宝玉兽」怪兽卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方主要怪兽区存在可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查（后半）：确认己方魔陷区存在至少1张可特殊召唤的「宝玉兽」怪兽卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 登记连锁的特殊召唤操作信息，预计从己方魔陷区特殊召唤至少1张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	-- 登记连锁的回复基本分操作信息，预计使己方回复基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- ①效果的处理流程：从己方魔陷区选1至2张「宝玉兽」怪兽卡特殊召唤，并按实际特殊召唤怪兽的原本攻击力合计使己方回复基本分
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向己方提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从己方魔陷区选择1至最多2张（且不超过空位数）满足条件的「宝玉兽」怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_SZONE,0,1,math.min(ft,2),nil,e,tp)
	if #g==0 then return end
	-- 将所选「宝玉兽」怪兽卡以表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 统计本次实际特殊召唤成功的怪兽原本攻击力总和
	local atk=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
	-- 以效果使己方回复等于该原本攻击力合计数值的基本分
	Duel.Recover(tp,atk,REASON_EFFECT)
end
-- 筛选条件：检查移动的卡是否为表侧表示、属于「宝玉兽」、己方控制且位于魔法与陷阱区域（序号小于5）
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- ②效果的发动条件检查：确认本次位置移动的卡片中存在放置到己方魔陷区的「宝玉兽」卡
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动检测：确认己方卡组有卡，且卡组顶的卡可加入手卡或己方可执行特殊召唤
function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（前半）：确认己方卡组至少还有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		-- 确认己方卡组最上方的卡可以加入手卡
		and (Duel.GetDecktopGroup(tp,1):IsExists(Card.IsAbleToHand,1,nil)
			-- 或者确认己方主要怪兽区有空位且己方可以进行特殊召唤
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp)
				-- 同时确认己方玩家未受到卡号63060238对应的特殊召唤限制标识影响
				and not Duel.IsPlayerAffectedByEffect(tp,63060238)) end
end
-- ②效果的处理流程：翻开己方卡组最上方1张卡，若为「宝玉兽」怪兽则让己方选择加入手卡或特殊召唤，否则送去墓地
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方是否可将卡组最上方1张卡送去墓地，否则终止处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开并确认己方卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取己方卡组最上方的这张翻开的卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=tc:IsAbleToHand()
	local b2=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if tc:IsSetCard(0x1034) and tc:IsType(TYPE_MONSTER) and (b1 or b2) then
		-- 若该「宝玉兽」怪兽可加入手卡，且无法特殊召唤或己方选择加入手卡分支，则执行加入手卡
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 禁用加入手卡操作前的卡组洗切检测
			Duel.DisableShuffleCheck()
			-- 以效果将该「宝玉兽」怪兽加入己方手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 禁用特殊召唤操作前的卡组洗切检测
			Duel.DisableShuffleCheck()
			-- 将该「宝玉兽」怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 禁用送去墓地操作前的卡组洗切检测
		Duel.DisableShuffleCheck()
		-- 若翻开的卡不是可处理的「宝玉兽」怪兽，则以翻卡效果将其送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
