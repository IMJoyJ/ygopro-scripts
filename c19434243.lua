--パワー・バイス・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有暗属性同调怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1只「共鸣者」怪兽加入手卡。这个回合，自己不是暗属性同调怪兽不能从额外卡组特殊召唤。
-- ③：用这张卡为同调素材把「红莲魔龙」同调召唤的场合，那只怪兽不会被战斗破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①特殊召唤、②检索共鸣者怪兽并限制召唤、③作为同调素材时红莲魔龙不被战斗破坏
function s.initial_effect(c)
	-- 记录该卡与「红莲魔龙」（卡号70902743）的关联，用于效果判定
	aux.AddCodeList(c,70902743)
	-- 效果①：自己场上的怪兽不存在的场合或者只有暗属性同调怪兽的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 效果②：这张卡特殊召唤的场合才能发动。从卡组把1只「共鸣者」怪兽加入手卡。这个回合，自己不是暗属性同调怪兽不能从额外卡组特殊召唤。
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
	-- 效果③：用这张卡为同调素材把「红莲魔龙」同调召唤的场合，那只怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(s.indcon)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在非暗属性同调怪兽或非正面表示的怪兽
function s.cfilter(c)
	return c:IsFacedown() or not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- 效果①的发动条件函数，判断场上是否不存在怪兽或仅存在暗属性同调怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否不存在怪兽或仅存在暗属性同调怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时的处理函数，判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数，将该卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索过滤函数，用于筛选「共鸣者」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动时处理函数，判断是否能检索共鸣者怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合条件的「共鸣者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理函数，选择并加入手牌，然后设置召唤限制效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的「共鸣者」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 设置召唤限制效果，禁止非暗属性同调怪兽从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册召唤限制效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 召唤限制效果的过滤函数，判断是否为非暗属性同调怪兽且在额外卡组
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果③的触发条件函数，判断是否因同调召唤而成为素材
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsCode(70902743)
end
-- 效果③的发动处理函数，为红莲魔龙添加不被战斗破坏的效果
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为红莲魔龙添加不被战斗破坏的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))  --"「强力恶龙」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
