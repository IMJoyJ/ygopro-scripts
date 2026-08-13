--白き森のルシア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有「白森林」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己抽1张。
-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己的场上·墓地1只「白森林」同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡效果无效特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数：为这张卡注册①手牌特殊召唤、②丢弃魔法·陷阱抽1、③墓地取对象特殊召唤并无效化三个效果，并分别设置1回合1次限制。
function s.initial_effect(c)
	-- ①：自己场上有「白森林」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，这张卡在墓地存在的场合，以自己的场上·墓地1只「白森林」同调怪兽为对象才能发动。那只怪兽回到额外卡组，这张卡效果无效特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"墓地特殊召唤"
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡是否为表侧表示且属于「白森林」字段的怪兽，用于①的场上存在检查。
function s.cfilter(c)
	return c:IsSetCard(0x1b1) and c:IsFaceup()
end
-- ①的发动条件：自己场上存在至少1只表侧表示且属于「白森林」字段的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足s.cfilter的表侧表示「白森林」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①的发动合法检查：自己的主要怪兽区有空位，且这张手牌怪兽可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否存在至少1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记特殊召唤的操作信息：本次效果将特殊召唤这张卡1只，供连锁检测与时点响应使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其从手卡表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断卡是否为魔法·陷阱卡且可以作为代价送去墓地，用于②选择要丢弃的卡。
function s.drfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- ②的代价处理：从自己的手卡·场上选择1张魔法·陷阱卡送去墓地作为发动代价。
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：自己的手卡或场上是否存在至少1张可作为代价的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·场上选择1张满足条件的魔法·陷阱卡作为代价。
	local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将所选卡片以代价原因（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②的发动检查与连锁信息设定：确认自己能抽1张卡，并记录抽卡玩家与抽卡数量。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以进行1次抽卡（未被‘不能抽卡’效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设为自己，表示抽卡玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记抽卡操作信息：本次效果由自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：根据连锁记录的目标玩家和抽卡数量执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的目标玩家和参数（抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③的取对象过滤：对象必须是表侧表示且属于「白森林」的同调怪兽，能回额外卡组，并且该对象离开后自己场上仍有怪兽区空位。
function s.spfilter2(c,tp)
	-- 检查对象离开后自己仍有怪兽区空位，且对象是表侧表示的同调怪兽。
	return Duel.GetMZoneCount(tp,c)>0 and c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
		and c:IsAbleToExtra() and c:IsSetCard(0x1b1)
end
-- ③的发动合法性与取对象检查：从自己场上·墓地选择1只满足条件的「白森林」同调怪兽作为对象，并确保这张卡可以被特殊召唤。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,tp) end
	-- 检查自己场上·墓地是否存在1只可作为对象且满足条件的「白森林」同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上·墓地选择1只「白森林」同调怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 登记操作信息：本次连锁包含将所选择的对象送回额外卡组，数量为g中卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,#g,0,0)
	-- 登记操作信息：本次连锁包含特殊召唤这张卡1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：若对象仍与效果关联且是怪兽，则将其送回额外卡组；成功后若这张卡仍与效果关联，则将其特殊召唤并附加‘效果无效’状态。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象仍与效果关联且是怪兽，并将其送回额外卡组；若送入成功（返回值≠0）则继续。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_EXTRA)
		-- 继续判断：若自己场上仍有怪兽区空位且这张卡仍与效果关联，则将这张卡以表侧表示纳入特殊召唤处理步骤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		c:RegisterEffect(e1)
		-- 这张卡效果无效特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，正式确定特殊召唤成功并触发相关时点。
	Duel.SpecialSummonComplete()
end
