--エンディミオンの侍女ジェニー
-- 效果：
-- 这个卡名在规则上也当作「魔女术」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有魔法师族怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：自己·对方的主要阶段，以自己场上1只魔法师族怪兽为对象才能发动。那只怪兽除外，从卡组把「恩底弥翁的侍女 杰妮」以外的1只「魔女术」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手牌特殊召唤的起动效果和场上除外并从卡组特殊召唤的诱发即时效果。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上有魔法师族怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，以自己场上1只魔法师族怪兽为对象才能发动。那只怪兽除外，从卡组把「恩底弥翁的侍女 杰妮」以外的1只「魔女术」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外并特殊召唤"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的魔法师族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果①的发动条件：自己场上存在表侧表示的魔法师族怪兽。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的魔法师族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检查（检查怪兽区域空位及自身是否能特殊召唤）。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的运行空间（效果处理）：将自身特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：自己或对方的主要阶段。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 过滤条件：自己场上表侧表示、可以被除外，且除外后能腾出怪兽区域空位给后续特殊召唤的魔法师族怪兽。
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
		-- 检查该怪兽离开场上后，是否能腾出至少1个可用于特殊召唤的怪兽区域空格。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤条件：卡组中「恩底弥翁的侍女 杰妮」以外的「魔女术」怪兽，且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与对象选择（选择自己场上1只魔法师族怪兽为对象）。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,tp) end
	-- 检查自己场上是否存在可以作为除外对象的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 并且检查卡组中是否存在可以特殊召唤的「魔女术」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只满足条件的魔法师族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁处理中的操作信息：除外选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_MZONE)
	-- 设置连锁处理中的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的运行空间（效果处理）：除外对象怪兽，并从卡组特殊召唤「魔女术」怪兽。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍存在且符合条件，并将其表侧表示除外，若除外成功则继续处理。
	if tc and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 检查自己场上是否有可用的怪兽区域空格，若无则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只「恩底弥翁的侍女 杰妮」以外的「魔女术」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
