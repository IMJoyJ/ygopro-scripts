--リブロマンサー・Gボーイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「书灵师」魔法卡加入手卡。
local s,id,o=GetID()
-- 创建并注册两个效果：①起动效果从手卡特殊召唤自身；②特殊召唤成功时从卡组检索「书灵师」魔法卡。
function s.initial_effect(c)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张「书灵师」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.d2htg)
	e2:SetOperation(s.d2hop)
	c:RegisterEffect(e2)
end
-- 筛选可作为①效果展示代价的卡：必须是手卡中的仪式怪兽，且当前不是公开状态。
function s.spcostfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- ①效果的发动代价处理：从手卡选择1只仪式怪兽给对方观看，然后洗切手卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查阶段判断手卡是否存在1只符合条件的仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 弹出“请选择给对方确认的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 由自己从手卡选择1张符合条件的仪式怪兽（不选择自身）作为展示对象。
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手卡。
	Duel.ShuffleHand(tp)
end
-- ①效果的发动条件判断：自己主要怪兽区有空位，且这张卡可以从手卡特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本次效果将要把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理时，若这张卡仍与效果关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选卡组中符合条件的「书灵师」魔法卡：属于「书灵师」字段、是魔法卡且能够加入手卡。
function s.d2hfilter(c)
	return c:IsSetCard(0x17c) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的发动条件判断：卡组中存在符合条件的「书灵师」魔法卡；同时设置从卡组加入手卡的操作信息。
function s.d2htg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1张符合条件的「书灵师」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.d2hfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时，从卡组选择1张「书灵师」魔法卡加入手卡，并让对方确认。
function s.d2hop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「书灵师」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.d2hfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
