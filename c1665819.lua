--レプリカルド・ラッド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡把1只其他的7星以上的怪兽除外才能发动。这张卡特殊召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽是卡名不同并是等级·攻击力·守备力之内有2个以上相同的1只怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
local s,id,o=GetID()
-- 为该卡注册两个效果：①从手牌除外其他7星以上怪兽将自身特殊召唤；②取自己场上表侧表示怪兽为对象，从卡组特殊召唤卡名不同且等级·攻击力·守备力中至少两项相同的怪兽，并使其本回合不能发动效果；两个效果均限制1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在的场合，从手卡把1只其他的7星以上的怪兽除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽是卡名不同并是等级·攻击力·守备力之内有2个以上相同的1只怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的代价筛选函数：判断手牌中的怪兽是否等级7以上且可以除外作为代价（不能是发动效果的这张卡）。
function s.costfilter(c)
	return c:IsLevelAbove(7) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：确认手牌存在符合条件的其他7星以上怪兽后，将其表侧除外作为发动代价。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动前检查：手牌中是否存在除自身以外、等级7以上且可作为代价除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 显示“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手牌选择1张满足代价条件的怪兽（过滤函数已排除发动效果的这张卡）。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的代价怪兽以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的Target函数：发动时确认主要怪兽区有空位，且这张卡自身可以被特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将把这张卡（自身）特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与当前连锁相关，则进行特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果从卡组选怪兽的筛选：卡名与对象怪兽不同、是怪兽、可被特殊召唤，且等级、攻击力、守备力中至少2项与对象数值相同。
function s.spfilter(c,e,tp,ec)
	if not (not c:IsCode(ec:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local tr=0
	if c:IsLevel(ec:GetLevel()) then tr=tr+1 end
	if c:IsAttack(ec:GetAttack()) then tr=tr+1 end
	if c:IsDefense(ec:GetDefense()) then tr=tr+1 end
	return tr>1
end
-- ②效果的对象筛选：自己场上的表侧表示怪兽，并且卡组中存在满足“卡名不同且等级/攻击/守备至少2项相同”的可特殊召唤怪兽。
function s.cfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
		-- 确认卡组中存在至少1张满足上述条件的可特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- ②效果的Target函数：对候选对象进行合法性确认，并检查主怪兽区有空位、场上存在符合条件的对象怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,e,tp) end
	-- 检查我方主要怪兽区是否有空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认场上存在可作为对象的表侧表示怪兽，且卡组中存在满足对应筛选条件的可特召怪兽。
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只自己场上表侧表示且满足条件的怪兽，并设置为效果对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将从卡组特殊召唤1只怪兽（具体怪兽未定，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：确认对象仍合法后，从卡组选择1只符合条件的怪兽特殊召唤，并附加本回合不能发动效果的限制。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理前检查：主怪兽区无空位、对象不再是怪兽或与连锁失去联系时，效果不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc:IsType(TYPE_MONSTER) or not tc:IsRelateToChain() then return end
	-- 显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足与对象怪兽卡名不同、等级/攻击/守备至少2项相同且可特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	-- 若选到了怪兽且特殊召唤步骤成功，则继续执行附加限制效果的处理。
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
		-- 完成特殊召唤步骤，并处理特殊召唤成功后的时点触发。
		Duel.SpecialSummonComplete()
	end
end
