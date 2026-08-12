--赤き竜
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把有「红龙」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ②：自己·对方回合，以除「红龙」外的场上1只7星以上的同调怪兽为对象才能发动。这张卡回到额外卡组，和作为对象的怪兽相同等级的1只龙族同调怪兽当作同调召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、苏生限制、以及①②效果的注册
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把有「红龙」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，以除「红龙」外的场上1只7星以上的同调怪兽为对象才能发动。这张卡回到额外卡组，和作为对象的怪兽相同等级的1只龙族同调怪兽当作同调召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中记述有「红龙」卡名的魔法·陷阱卡且能加入手牌的过滤函数
function s.thfilter(c)
	-- 检查卡片是否记述有「红龙」卡名、是否为魔法或陷阱卡、以及是否能加入手牌
	return aux.IsCodeListed(c,id) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target）函数，检查卡组中是否存在符合条件的卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果的处理包含从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的执行（Operation）函数，从卡组选择1张符合条件的卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上除「红龙」以外、等级7以上且表侧表示的同调怪兽，并且额外卡组中存在可特殊召唤的对应龙族同调怪兽
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
		-- 检查额外卡组中是否存在与该怪兽等级相同、且满足特殊召唤条件的龙族同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel(),e:GetHandler())
end
-- 过滤额外卡组中等级与目标怪兽相同、是龙族同调怪兽、且能被特殊召唤的卡
function s.spfilter(c,e,tp,lv,ec)
	return c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
		-- 检查在将自身（红龙）送回额外卡组后，额外怪兽区域是否有空位用于特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
-- ②效果的发动准备（Target）函数，处理取对象判定、检查自身是否能回额外卡组以及是否存在合法对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查是否存在必须作为同调素材的限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查场上是否存在至少1个满足过滤条件的可取对象怪兽
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只场上满足过滤条件的怪兽作为效果对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息，表示此效果的处理包含将自身（红龙）送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示此效果的处理包含从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的执行（Operation）函数，将自身送回额外卡组，并将与对象怪兽相同等级的1只龙族同调怪兽当作同调召唤特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否受效果影响，并将其送回额外卡组，确认成功回到额外卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA)
		and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 再次检查必须作为同调素材的限制，若不满足则无法继续特殊召唤
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择1只与对象怪兽等级相同的龙族同调怪兽
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetLevel(),nil):GetFirst()
		if sc then
			sc:SetMaterial(nil)
			-- 将选择的怪兽当作同调召唤特殊召唤到场上，并检查是否特殊召唤成功
			if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
		end
	end
end
