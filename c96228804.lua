--聖月の皇太子レグルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，把手卡1只其他的魔法师族怪兽给对方观看才能发动。自己失去给人观看的怪兽的等级×300基本分，这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把有「圣月之皇太子 雷古勒斯」的卡名记述的1张魔法卡加入手卡。
-- ③：这张卡1回合只有1次不会被战斗破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 注册卡片记述的卡名（本卡自身，用于检索相关卡）
	aux.AddCodeList(c,id)
	-- ①：这张卡在手卡存在的场合，把手卡1只其他的魔法师族怪兽给对方观看才能发动。自己失去给人观看的怪兽的等级×300基本分，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把有「圣月之皇太子 雷古勒斯」的卡名记述的1张魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡1回合只有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(s.valcon)
	c:RegisterEffect(e3)
end
-- 过滤手牌中未给对方观看的魔法师族怪兽
function s.cfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsPublic()
end
-- 效果①的Cost处理（展示手牌中1只其他的魔法师族怪兽，并记录其等级）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在除自身以外的、未给对方观看的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手牌中1只其他的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	-- 给对方玩家确认选择的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果①的Target处理（检查怪兽区域空格以及自身是否能特殊召唤）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的Operation处理（扣除基本分并特殊召唤自身）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 扣除自身基本分，数值为展示怪兽的等级×300
	Duel.SetLP(tp,Duel.GetLP(tp)-e:GetLabel()*300)
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中记述有「圣月之皇太子 雷古勒斯」卡名的魔法卡
function s.thfilter(c)
	-- 检查卡片是否记述有本卡卡名、是否为魔法卡以及是否能加入手牌
	return aux.IsCodeListed(c,id) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果②的Target处理（检查卡组中是否存在符合条件的魔法卡）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在记述有本卡卡名的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation处理（从卡组检索符合条件的魔法卡）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1张记述有本卡卡名的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的破坏抗性条件判定（仅在战斗破坏时适用）
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
