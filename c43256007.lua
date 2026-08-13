--氷結界の随身
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从手卡把1只5星以上的「冰结界」怪兽特殊召唤。
-- ②：这个回合没有送去墓地的这张卡在墓地存在的场合，以自己场上1只3星以上的水属性怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c43256007.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡解放才能发动。从手卡把1只5星以上的「冰结界」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43256007,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,43256007)
	e1:SetCost(c43256007.spcost1)
	e1:SetTarget(c43256007.sptg1)
	e1:SetOperation(c43256007.spop1)
	c:RegisterEffect(e1)
	-- ②：这个回合没有送去墓地的这张卡在墓地存在的场合，以自己场上1只3星以上的水属性怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43256007,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动条件：这张卡不是本回合被送去墓地（即“这个回合没有送去墓地”的场合）才能发动。
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,43256008)
	e2:SetTarget(c43256007.sptg2)
	e2:SetOperation(c43256007.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：在确认代价时检查这张卡是否可解放，若可解放则解放自身作为发动代价。
function c43256007.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价形式解放这张卡（REASON_COST），对应“把这张卡解放才能发动”的代价处理。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ①效果的特殊召唤筛选条件：手牌中满足「冰结界」字段、5星以上且可以被效果特殊召唤的怪兽。
function c43256007.spfilter1(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件：自己解放自身后至少有一个可用的怪兽区域，且手牌存在1只符合条件的「冰结界」怪兽。
function c43256007.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区在解放自身后是否至少有一个空位（当前可用数>=-1，即解放后>=0，因为解放自身会腾出1个格子）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并检查手牌是否存在至少1只满足spfilter1条件的「冰结界」怪兽（5星以上且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c43256007.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果属于特殊召唤，预计从手牌特殊召唤1只怪兽，用于其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：确认有可用怪兽区域后，从手牌选择1只符合条件的「冰结界」怪兽，以表侧表示特殊召唤。
function c43256007.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再确认自己怪兽区是否有空位；若没有则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，提示玩家“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的「冰结界」怪兽。
	local g=Duel.SelectMatchingCard(tp,c43256007.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果对象怪兽的筛选条件：表侧表示、等级3以上、水属性。
function c43256007.spfilter2(c)
	return c:IsFaceup() and c:IsLevelAbove(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ②效果的发动条件与取对象：选择自己场上1只表侧表示且等级3以上的水属性怪兽为对象，同时自己怪兽区有空位且墓地中的自身可特殊召唤。
function c43256007.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43256007.spfilter2(chkc) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在1只满足条件的水属性怪兽，可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c43256007.spfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 并检查自己怪兽区有空位，且墓地中的这张卡本身可以被特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 显示选择提示，让玩家选择表侧表示的水属性怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只符合条件的自己场上的水属性怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c43256007.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果将特殊召唤墓地中的这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：对象怪兽等级下降2星；若成功且自身仍可特殊召唤，则将自身特殊召唤，并附加离场时除外的效果。
function c43256007.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<3 then return end
	local c=e:GetHandler()
	-- 对应原文“那只怪兽的等级下降2星”：为对象怪兽附加等级下降2星的持续效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-2)
	tc:RegisterEffect(e1)
	-- 若对象怪兽不免疫降等级效果、自身仍与效果关联，则尝试特殊召唤自身；特殊召唤成功时才继续附加除外效果。
	if not tc:IsImmuneToEffect(e1) and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 对应原文“这个效果特殊召唤的这张卡从场上离开的场合除外”：给这张卡附加离场时改为除外的永续效果（且不会被无效）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
end
