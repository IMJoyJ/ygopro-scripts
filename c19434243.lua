--パワー・バイス・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有暗属性同调怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1只「共鸣者」怪兽加入手卡。这个回合，自己不是暗属性同调怪兽不能从额外卡组特殊召唤。
-- ③：用这张卡为同调素材把「红莲魔龙」同调召唤的场合，那只怪兽不会被战斗破坏。
local s,id,o=GetID()
-- 初始化强力恶龙的效果：分别注册①手牌特殊召唤效果、②特殊召唤成功时检索「共鸣者」并附加额外自肃效果、③作为「红莲魔龙」同调素材时赋予其战斗破坏抗性的效果。
function s.initial_effect(c)
	-- 将卡号70902743（红莲魔龙）加入代码列表，标记这张卡文本中记载了该卡，用于‘记载卡名’相关规则判定。
	aux.AddCodeList(c,70902743)
	-- ①：自己场上的怪兽不存在的场合或者只有暗属性同调怪兽的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把1只「共鸣者」怪兽加入手卡。这个回合，自己不是暗属性同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：用这张卡为同调素材把「红莲魔龙」同调召唤的场合，那只怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(s.indcon)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
end
-- 定义筛选函数：若怪兽为里侧表示或不是暗属性同调怪兽，则返回true，用于判断①的发动条件不满足。
function s.cfilter(c)
	return c:IsFacedown() or not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- ①效果的发动条件：自己场上不存在非表侧暗属性同调怪兽，即场上没有怪兽或只有表侧暗属性同调怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在任意1张不满足条件的怪兽；不存在则返回true，满足①发动前条件。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的目标检测：确认主要怪兽区有空位，并且手卡的这张卡可以以表侧表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有空位用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤这张卡1张，告知系统后续处理将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍在连锁中，将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤函数：筛选卡组中1只「共鸣者」系列怪兽，且该卡可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标检测：确认卡组中存在符合条件的「共鸣者」怪兽，并设置操作信息为加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只符合条件的「共鸣者」怪兽，存在才能发动②。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1只「共鸣者」怪兽加入手卡并展示，然后给对方和自己附加‘这个回合不能从额外卡组特殊召唤非暗属性同调怪兽’的自肃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片提示，让玩家选择要加入手卡的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组选择1张符合过滤条件的「共鸣者」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的「共鸣者」怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家，确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不是暗属性同调怪兽不能从额外卡组特殊召唤。③：用这张卡为同调素材把「红莲魔龙」同调召唤的场合，那只怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册为影响当前玩家的场地效果，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃条件：从额外卡组特殊召唤的怪兽若不是暗属性同调怪兽，则不能特殊召唤。
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- ③的触发条件：这张卡作为同调素材被使用，且同调召唤出的怪兽是「红莲魔龙」（70902743）。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsCode(70902743)
end
-- ③的处理操作：给同调召唤出的「红莲魔龙」附加不会被战斗破坏的效果。
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：用这张卡为同调素材把「红莲魔龙」同调召唤的场合，那只怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))  --"「强力恶龙」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
