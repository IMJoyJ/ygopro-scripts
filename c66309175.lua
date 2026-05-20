--捕食植物アンブロメリドゥス
-- 效果：
-- 「捕食植物」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从自己的卡组·额外卡组（表侧）·墓地把1只「捕食植物」怪兽或1张「捕食」魔法·陷阱卡加入手卡。
-- ②：以1只对方场上的有捕食指示物放置的怪兽或者自己场上的怪兽为对象才能发动。那只怪兽解放，从卡组把1只「捕食植物」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：设置融合召唤手续，注册①效果（融合召唤成功时检索/回收）和②效果（取场上怪兽为对象解放并从卡组特召）。
function c66309175.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：需要2只「捕食植物」怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),2,true)
	-- ①：这张卡融合召唤的场合才能发动。从自己的卡组·额外卡组（表侧）·墓地把1只「捕食植物」怪兽或1张「捕食」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66309175,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,66309175)
	e1:SetCondition(c66309175.thcon)
	e1:SetTarget(c66309175.thtg)
	e1:SetOperation(c66309175.thop)
	c:RegisterEffect(e1)
	-- ②：以1只对方场上的有捕食指示物放置的怪兽或者自己场上的怪兽为对象才能发动。那只怪兽解放，从卡组把1只「捕食植物」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66309175,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66309175+o)
	e2:SetTarget(c66309175.sptg)
	e2:SetOperation(c66309175.spop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否是通过融合召唤特殊召唤的。
function c66309175.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤可以加入手牌的卡：必须是「捕食」卡片，且如果是怪兽则必须是「捕食植物」怪兽，且在额外卡组时必须是表侧表示。
function c66309175.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0xf3) and (not c:IsType(TYPE_MONSTER) or c:IsSetCard(0x10f3)) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
-- ①效果的发动准备：检查卡组、墓地、额外卡组是否存在可加入手牌的卡，并设置将卡加入手牌的操作信息。
function c66309175.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组、墓地、额外卡组是否存在至少1张满足条件的「捕食」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c66309175.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁的操作信息：从卡组、墓地或额外卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ①效果的效果处理：从卡组、墓地或额外卡组选择1张满足条件的卡加入手牌，并给对方确认。
function c66309175.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 过滤并选择1张不受王家长眠之谷影响的、满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66309175.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤可以作为解放对象的怪兽：必须能被效果解放，且必须是自己场上的怪兽或者对方场上有捕食指示物放置的怪兽，且解放后必须能空出至少1个怪兽区域。
function c66309175.relfilter(c,tp)
	-- 检查怪兽是否能被效果解放，且满足（有捕食指示物或由自己控制），且解放该怪兽后自己场上有可用的怪兽区域。
	return c:IsReleasableByEffect() and (c:GetCounter(0x1041)>0 or c:IsControler(tp)) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤可以特殊召唤的怪兽：必须是「捕食植物」怪兽，且可以被特殊召唤。
function c66309175.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：进行取对象判定，检查场上是否存在可解放的怪兽以及卡组中是否存在可特召的「捕食植物」怪兽，并选择解放对象。
function c66309175.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c66309175.relfilter(chkc,tp) end
	-- 检查场上是否存在至少1只满足解放条件的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c66309175.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		-- 检查自己的卡组中是否存在至少1只可以特殊召唤的「捕食植物」怪兽。
		and Duel.IsExistingMatchingCard(c66309175.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只满足解放条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c66309175.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：解放作为对象的怪兽，并从卡组特殊召唤1只「捕食植物」怪兽。
function c66309175.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将对象怪兽用效果解放，若解放成功且自己场上有可用的怪兽区域，则继续处理。
		and Duel.Release(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只可以特殊召唤的「捕食植物」怪兽。
		local g=Duel.SelectMatchingCard(tp,c66309175.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
