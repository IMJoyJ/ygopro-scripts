--インフェルノクインサーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只鱼族通常怪兽特殊召唤。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。在自己场上把「地狱兵卒鲑衍生物」（鱼族·水·1星·攻/守0）任意数量特殊召唤。
function c27882993.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只鱼族通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27882993,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27882993)
	e1:SetTarget(c27882993.sptg)
	e1:SetOperation(c27882993.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。在自己场上把「地狱兵卒鲑衍生物」（鱼族·水·1星·攻/守0）任意数量特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27882993,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,27882994)
	e3:SetCondition(c27882993.tokcon)
	e3:SetTarget(c27882993.toktg)
	e3:SetOperation(c27882993.tokop)
	c:RegisterEffect(e3)
end
-- 定义①效果可特殊召唤的怪兽筛选条件：是通常怪兽、鱼族，且能够被当前效果以表侧表示特殊召唤。
function c27882993.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的目标判定：确认自己主要怪兽区有空位，且手卡/卡组/墓地存在至少1只满足spfilter的鱼族通常怪兽，才可发动。
function c27882993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格，作为①效果的发动前提之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡/卡组/墓地中是否存在至少1张满足spfilter（鱼族通常怪兽且可特殊召唤）的卡，作为①效果的发动前提之一。
		and Duel.IsExistingMatchingCard(c27882993.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本效果将从手卡/卡组/墓地特殊召唤1只怪兽，供连锁判定等系统逻辑使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理：再次确认空格后提示玩家从手卡/卡组/墓地选择1只鱼族通常怪兽（会排除受王家长眠之谷影响的卡），并将其表侧表示特殊召唤到自己场上。
function c27882993.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前复查自己场上主要怪兽区是否有空格，若没有则跳过特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示选择提示文本『请选择要特殊召唤的卡』，用于接下来的选卡操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡/卡组/墓地选择1张满足spfilter且不受王家长眠之谷影响的鱼族通常怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27882993.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到该玩家场上；此操作会正常检查苏生限制与召唤条件。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡因战斗被破坏，或者被对方发动的效果破坏且破坏前控制权属于自己。
function c27882993.tokcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- ②效果的发动判定：自己场上主要怪兽区有空位，且玩家能够特殊召唤『地狱兵卒鲑衍生物』（鱼族·水·1星·攻/守0）。
function c27882993.toktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格，作为②效果的发动前提之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否满足特殊召唤『地狱兵卒鲑衍生物』token的全部条件（种族/属性/等级/攻防及规则限制）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27882994,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_WATER) end
	-- 登记操作信息：本次效果包含生成衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记操作信息：本次效果包含特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果的处理：计算可特招衍生物数量上限（默认5只，若青眼精灵龙生效则1只，并取场上空格数），随后循环创建衍生物并逐步特殊召唤，期间由玩家决定是否继续，最后统一完成特殊召唤。
function c27882993.tokop(e,tp,eg,ep,ev,re,r,rp)
	local ft=5
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 将本次可特殊召唤的衍生物数量上限修正为当前自己场上主要怪兽区的空格数（取较小值）。
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 若可特殊召唤数量小于等于0，或玩家无法特殊召唤该衍生物，则终止效果处理。
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,27882994,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_WATER) then return end
	repeat
		-- 创建一只『地狱兵卒鲑衍生物』token（卡号27882994）。
		local token=Duel.CreateToken(tp,27882994)
		-- 将生成的衍生物作为特殊召唤过程的一步，以表侧表示特殊召唤到tp的场上。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
	-- 判断是否继续生成下一只衍生物：当剩余空格数大于0且玩家选择『是』时继续循环，否则停止。
	until ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(27882993,2))  --"是否继续特殊召唤？"
	-- 完成衍生物的特殊召唤处理，使所有通过SpecialSummonStep登记的衍生物统一特殊召唤上场。
	Duel.SpecialSummonComplete()
end
