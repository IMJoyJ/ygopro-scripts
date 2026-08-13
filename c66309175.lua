--捕食植物アンブロメリドゥス
-- 效果：
-- 「捕食植物」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从自己的卡组·额外卡组（表侧）·墓地把1只「捕食植物」怪兽或1张「捕食」魔法·陷阱卡加入手卡。
-- ②：以1只对方场上的有捕食指示物放置的怪兽或者自己场上的怪兽为对象才能发动。那只怪兽解放，从卡组把1只「捕食植物」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置融合素材手续，并注册①效果（融合召唤成功的场合触发的检索·加手效果）和②效果（解放怪兽并从卡组特殊召唤的起动效果）
function c66309175.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续：用2只「捕食植物」怪兽作为融合素材
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
c66309175.mentioned_counter={
	[0x1041]=true,
}
-- ①效果的发动条件：这张卡是用融合召唤出场的
function c66309175.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索对象过滤条件：可以加入手卡，且是「捕食」卡中的「捕食植物」怪兽或者「捕食」魔法·陷阱卡，并且在额外卡组的场合需为表侧表示
function c66309175.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0xf3) and (not c:IsType(TYPE_MONSTER) or c:IsSetCard(0x10f3)) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
-- ①效果的对象处理：检查卡组·墓地·额外卡组是否存在可加入手卡的满足条件的卡，并设置回手牌的操作信息
function c66309175.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的卡组·墓地·额外卡组存在至少1张满足条件的可以加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66309175.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：宣言将从卡组·墓地·额外卡组把1张卡加入手卡（对象在处理时确定，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ①效果的处理：让玩家选择1张满足条件的卡（不受王家长眠之谷影响），将其加入手卡，并给对方确认
function c66309175.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组·墓地·额外卡组选择1张满足条件且不受王家长眠之谷影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66309175.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的对象过滤条件：可以被效果解放，是对方场上有捕食指示物放置的怪兽或者自己场上的怪兽，且其离开后自己场上还有可用的怪兽区
function c66309175.relfilter(c,tp)
	-- 判断该卡能否被效果解放、是否放置有捕食指示物或是自己控制的怪兽，以及解放后自己场上是否还有空怪兽区
	return c:IsReleasableByEffect() and (c:GetCounter(0x1041)>0 or c:IsControler(tp)) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤对象过滤条件：卡组中可以特殊召唤的「捕食植物」怪兽
function c66309175.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的对象选择处理：验证连锁对象是否合法，检查是否存在可取为对象的可解放怪兽且卡组存在可特殊召唤的「捕食植物」怪兽
function c66309175.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c66309175.relfilter(chkc,tp) end
	-- 发动条件检查：双方怪兽区存在至少1只可以取为对象的满足解放条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c66309175.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		-- 发动条件检查：卡组存在至少1只可以特殊召唤的「捕食植物」怪兽
		and Duel.IsExistingMatchingCard(c66309175.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家：请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从双方怪兽区选择1只满足解放条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66309175.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：宣言将从卡组把1只怪兽特殊召唤（对象在处理时确定，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：把对象的怪兽解放，之后若自己场上还有空怪兽区，则从卡组选1只「捕食植物」怪兽以表侧表示特殊召唤
function c66309175.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要解放的那只怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 对象仍与此效果关联且不受效果免疫时，将其以效果原因解放，并确认自己场上还有可用的怪兽区
		and Duel.Release(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只可以特殊召唤的「捕食植物」怪兽
		local g=Duel.SelectMatchingCard(tp,c66309175.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 把选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
