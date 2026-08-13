--地縛囚人 ライン・ウォーカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「地缚牢」或「异界共鸣-同调融合」加入手卡。
-- ②：自己场上有6星以上的「地缚」怪兽存在的场合，把墓地的这张卡除外，以从额外卡组特殊召唤的对方场上1只效果怪兽为对象才能发动。那只效果怪兽回到卡组。那之后，对方可以把那1只同名怪兽从自身的额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：将卡名记载的两张关联卡加入代码列表，并分别注册①的召唤/特殊召唤诱发检索效果与②的墓地起动效果。
function s.initial_effect(c)
	-- 将卡名中提到的「地缚牢」（71089030）和「异界共鸣-同调融合」（7473735）加入代码列表，用于支持该卡效果对其卡名的检索与判断。
	aux.AddCodeList(c,71089030,7473735)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「地缚牢」或「异界共鸣-同调融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上有6星以上的「地缚」怪兽存在的场合，把墓地的这张卡除外，以从额外卡组特殊召唤的对方场上1只效果怪兽为对象才能发动。那只效果怪兽回到卡组。那之后，对方可以把那1只同名怪兽从自身的额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.tdcon)
	-- 设置发动代价：将墓地中的这张卡除外作为发动②效果所需的cost。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 定义①效果的检索过滤条件：卡名必须为「地缚牢」或「异界共鸣-同调融合」，且能够被加入手卡。
function s.filter(c)
	return c:IsCode(71089030,7473735) and c:IsAbleToHand()
end
-- ①效果的发动条件检查与操作信息设置：确认卡组或墓地存在符合条件的检索对象，并预设置1张加入手卡的处理信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：自己的卡组·墓地中是否存在至少1张满足s.filter的卡片，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组·墓地加入手卡，目标玩家为自己，范围为卡组+墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从自己的卡组·墓地将1张「地缚牢」或「异界共鸣-同调融合」加入手卡，并让对方确认加入手卡的卡片。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选卡提示框，提示当前玩家选择一张要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1张满足检索条件且不受王家长眠之谷影响的卡片（使用NecroValleyFilter过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入其持有者的手卡（nil表示返回持有者），移动原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开显示本次加入手卡的卡片，以便对方确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果发动条件的过滤函数：自己场上有表侧表示、等级6以上且属于「地缚」系列的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsSetCard(0x21)
end
-- ②效果的发动条件判定：自己场上存在至少1只满足s.cfilter的「地缚」怪兽时才允许发动。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区是否存在至少1只表侧表示6星以上的「地缚」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义②效果可选择的对方怪兽条件：表侧表示、效果怪兽、从额外卡组特殊召唤，且当前能够返回卡组。
function s.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- ②效果的取对象流程：选择对方场上1只从额外卡组特殊召唤的效果怪兽作为对象，并设置返回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.dfilter(chkc) end
	-- 发动时检查对方场上是否存在至少1只满足s.dfilter并能够成为效果对象的怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选卡提示框，提示当前玩家选择一张要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方场上选择1只满足s.dfilter的怪兽作为效果对象，并自动将其与该连锁效果建立联系。
	local g=Duel.SelectTarget(tp,s.dfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将把选择的对象返回持有者卡组（数量1），供后续相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 定义后续特殊召唤的过滤函数：从对方额外卡组中筛选与返回卡组怪兽同名的卡片（...为同名卡号），且该卡可以被对方玩家特殊召唤。
function s.sfilter(c,e,tp,...)
	return c:IsCode(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外卡组怪兽特殊召唤的场地限制：确认对方的额外怪兽区或可用主要怪兽区存在可特殊召唤的空位。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果处理：将对象怪兽返回卡组洗牌；若成功且该怪兽进入卡组或额外卡组，则询问对方是否从额外卡组特殊召唤1只同名怪兽，并根据选择进行特殊召唤。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)
		-- 将对象怪兽以效果返回持有者卡组并洗牌，返回实际处理数量需大于0才判定为弹回成功。
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 从对方额外卡组中筛选与返回卡组怪兽同名的、可被对方特殊召唤且满足出场条件的卡片集合。
		local g=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_EXTRA,nil,e,1-tp,tc:GetCode())
		-- 若存在符合条件的同名怪兽，则询问对方玩家“是否特殊召唤同名怪兽”，对方选择是才继续处理。
		if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤同名怪兽？"
			-- 弹出特殊召唤选卡提示框，提示对方玩家选择一张要特殊召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 中断当前效果处理，使后续对方玩家的特殊召唤作为独立时点处理，避免错过相关时点。
			Duel.BreakEffect()
			-- 对方玩家将选择的同名怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制，由对方玩家操作）。
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
