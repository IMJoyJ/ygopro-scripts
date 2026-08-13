--U.A.コリバルリバウンダー
-- 效果：
-- 「超级运动员 角逐篮板手」的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让「超级运动员 角逐篮板手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：这张卡召唤或者对方回合中的特殊召唤成功的场合才能发动。从自己的手卡·墓地选「超级运动员 角逐篮板手」以外的1只「超级运动员」怪兽特殊召唤。
function c17264592.initial_effect(c)
	-- 「超级运动员 角逐篮板手」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 角逐篮板手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,17264592+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c17264592.sprcon)
	e1:SetTarget(c17264592.sprtg)
	e1:SetOperation(c17264592.sprop)
	c:RegisterEffect(e1)
	-- 「超级运动员 角逐篮板手」的②的效果1回合只能使用1次。②：这张卡召唤或者对方回合中的特殊召唤成功的场合才能发动。从自己的手卡·墓地选「超级运动员 角逐篮板手」以外的1只「超级运动员」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,17264593)
	e2:SetTarget(c17264592.sptg)
	e2:SetOperation(c17264592.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c17264592.spcon)
	c:RegisterEffect(e3)
end
-- 定义①效果特殊召唤时的返回手牌代价过滤条件：选择自己场上表侧表示、属于「超级运动员」系列、不是本卡、且可作为代价返回手牌的怪兽；同时需要满足该怪兽返回手牌后自己场上仍有可用怪兽区。
function c17264592.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(17264592) and c:IsAbleToHandAsCost()
		-- 追加判定：该怪兽返回手牌后，自己场上仍有至少1个可用怪兽区域，用于特殊召唤本卡。
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①规则特殊召唤的条件：若从手卡特殊召唤本卡，需确认自己场上存在满足返回手牌代价的「超级运动员」怪兽；参数c为空时不额外限制。
function c17264592.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足返回手牌代价条件的「超级运动员」怪兽。
	return Duel.IsExistingMatchingCard(c17264592.thfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- ①特殊召唤手续中的选择过程：从符合条件的一组卡中让玩家选择1只要返回手牌的怪兽，并将其记录到效果对象中，作为特殊召唤所需的代价。
function c17264592.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足返回手牌代价条件的「超级运动员」怪兽，组成候选集合。
	local g=Duel.GetMatchingGroup(c17264592.thfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向玩家显示选择提示：请选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行①特殊召唤的处理：将之前选定的怪兽返回手牌，完成从手卡特殊召唤本卡的手续。
function c17264592.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽返回持有者手牌，作为特殊召唤手续的组成部分。
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果的特殊召唤对象过滤条件：属于「超级运动员」系列、不是本卡，且能够被效果特殊召唤。
function c17264592.spfilter(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(17264592)
end
-- ②效果的发动判定：自己场上主要怪兽区有空位，并且手牌·墓地中存在至少1只符合条件的「超级运动员」怪兽。
function c17264592.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌·墓地中是否存在至少1只符合条件的「超级运动员」怪兽。
		and Duel.IsExistingMatchingCard(c17264592.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，声明将进行1只「超级运动员」怪兽的特殊召唤，对象从手牌·墓地中选择（因不取对象，目标暂为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：在仍有怪兽区空位的前提下，从自己的手牌·墓地选择1只符合条件的「超级运动员」怪兽特殊召唤。
function c17264592.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有可用怪兽区，否则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌·墓地选择1张符合条件且不受王家长眠之谷影响的「超级运动员」怪兽（墓地特殊召唤过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17264592.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果在对方回合特殊召唤成功时的发动条件：当前回合玩家不是这张卡的控制者，即这张卡是在对方回合被特殊召唤的。
function c17264592.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家与效果发动者不是同一人，以确认这是对方回合中的特殊召唤。
	return Duel.GetTurnPlayer()~=tp
end
