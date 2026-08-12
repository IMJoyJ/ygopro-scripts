--占い魔女 フウちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合，以除外的1只自己的魔法师族怪兽为对象才能发动。那只怪兽加入手卡。
function c79890560.initial_effect(c)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79890560,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,79890560)
	e1:SetCost(c79890560.spcost)
	e1:SetTarget(c79890560.sptg)
	e1:SetOperation(c79890560.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡的特殊召唤成功的场合，以除外的1只自己的魔法师族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79890560,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,79890561)
	e2:SetCondition(c79890560.thcon)
	e2:SetTarget(c79890560.thtg)
	e2:SetOperation(c79890560.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）判定：这张卡在手卡中且未给对方观看（非公开状态）。
function c79890560.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①的发动条件与目标判定：检查自身是否能特殊召唤以及场上是否有空位。
function c79890560.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判定己方主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：若自身仍存在于手卡，则将自身以表侧表示特殊召唤。
function c79890560.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件判定：这张卡必须是从手卡特殊召唤成功。
function c79890560.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤条件：除外的表侧表示、魔法师族且能加入手卡的怪兽。
function c79890560.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 效果②的发动准备：选择除外的1只自己的魔法师族怪兽作为对象，并设置加入手卡的操作信息。
function c79890560.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c79890560.thfilter(chkc) end
	-- 判定除外区是否存在符合条件的己方魔法师族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c79890560.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只符合条件的己方魔法师族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c79890560.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置回收卡片的操作信息，表示将选中的卡片加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽加入手卡。
function c79890560.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
