--二つの心
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，①②的效果在同一连锁上不能发动。
-- ①：自己·对方回合可以发动。从卡组把有「光与暗的仪式」的卡名记述的1只怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：对方把卡的效果发动时，让自己场上1只7星以上的怪兽回到手卡才能发动。把和回去的怪兽卡名不同的有「光与暗的仪式」的卡名记述的1只怪兽从手卡无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册“两颗心灵”的卡片效果：①自己·对方回合从卡组检索记述有「光与暗的仪式」的怪兽后丢弃1张手卡的效果，②对方发动卡的效果时通过将自己场上7星以上怪兽回手来特殊召唤手卡对应怪兽的效果，并限制这两个效果在同一连锁上发动
function s.initial_effect(c)
	-- 添加「光与暗的仪式」的卡名记述关联，以便相关效果可以检测此卡
	aux.AddCodeList(c,33599853)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合可以发动。从卡组把有「光与暗的仪式」的卡名记述的1只怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：对方把卡的效果发动时，让自己场上1只7星以上的怪兽回到手卡才能发动。把和回去的怪兽卡名不同的有「光与暗的仪式」的卡名记述的1只怪兽从手卡无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己卡组中记述了「光与暗的仪式」卡名的怪兽卡，且可以加入手卡
function s.thfilter(c)
	-- 判断卡片是否在文本中记述了「光与暗的仪式」的卡名、是否是怪兽卡且能加入手卡
	return aux.IsCodeListed(c,33599853) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：判断自己卡组中是否存在记述「光与暗的仪式」的怪兽，并且当前连锁中自己没有发动过效果②，并设置检索与丢弃手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组中是否存在可检索的记述了「光与暗的仪式」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断当前连锁中自己是否未发动效果②（同一连锁上不能发动的限制检测）
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 在当前连锁中注册已发动效果①的标识（以防同一连锁中再发动效果②）
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的操作处理：从卡组将记述有「光与暗的仪式」的1只怪兽加入手卡，然后从手卡选择1张卡丢弃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示：请选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将选中的怪兽展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 给玩家发送提示：请选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 让玩家从手卡中选择1张可以丢弃的卡片
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			-- 中断效果处理，使之后的效果处理与之前的检索不视为同时处理
			Duel.BreakEffect()
			-- 手动切洗玩家的手牌
			Duel.ShuffleHand(tp)
			-- 将玩家选择的卡片送去墓地并视为因效果丢弃
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 效果②的发动条件：对方发动卡的效果时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 过滤条件：自己场上表侧表示存在的、等级7以上且可以因Cost返回手卡的怪兽，且其离场后有可用怪兽区域，且自己手卡中存在与之不同名的记述有「光与暗的仪式」的可以特召的怪兽
function s.cfilter(c,e,tp)
	-- 判断卡片是否表侧表示存在、等级在7星以上、能因Cost回到手卡且返回后能腾出空位
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 判断自己手卡中是否存在与该怪兽不同名的、且记述有「光与暗的仪式」的可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 效果②的Cost处理：验证是否可发动，并选择自己场上1只符合条件的怪兽返回手卡，同时记录该怪兽的卡名
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 验证当前是否可以进行Cost处理（场上是否有可以回手且能引发特召的7星以上怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给玩家发送提示：请选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1只自己场上的符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 手动显示该怪兽被选择的动画效果
	Duel.HintSelection(g)
	-- 将选中的怪兽的卡号（卡名）保存到连锁对象参数中，供效果处理时读取
	Duel.SetTargetParam(g:GetFirst():GetCode())
	-- 将选中的怪兽返回持有者的手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 过滤条件：手卡中记述有「光与暗的仪式」的怪兽，且卡名与通过Cost返回手卡的怪兽不同，且可以无视召唤条件特殊召唤
function s.spfilter(c,e,tp,code)
	-- 判断卡片是否在文本中记述了「光与暗的仪式」的卡名，且是怪兽卡
	return aux.IsCodeListed(c,33599853) and c:IsType(TYPE_MONSTER)
		and (not code or c:GetCode()~=code)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动准备：判断是否已经执行过Cost，且当前连锁中没有发动过效果①，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 判断当前连锁中自己是否未发动效果①（同一连锁上不能发动的限制检测）
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册已发动效果②的标识（以防同一连锁中再发动效果①）
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的操作处理：从手卡把和回去的怪兽卡名不同的有「光与暗的仪式」卡名记述的1只怪兽无视召唤条件特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否还有空位，若无则直接结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 给玩家发送提示：请选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从连锁信息中获取Cost返回手卡的怪兽的卡号
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 让玩家从手卡中选择1只符合特召条件且与Cost返回怪兽不同名的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,code)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
