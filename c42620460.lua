--クロノダイバー・パワーリザーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成通常怪兽（念动力族·暗·4星·攻1900/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从自己的手卡·卡组·墓地把1只机械族「时间潜行者」怪兽特殊召唤。
-- ②：有魔法卡和陷阱卡在作为超量素材中的超量怪兽在自己场上存在的场合，把墓地的这张卡除外才能发动。场上1张卡除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册①发动后作为陷阱怪兽特召并追召机械族「时间潜行者」怪兽的效果，以及②墓地除外自身并除外场上1张卡的二速效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡发动后变成通常怪兽（念动力族·暗·4星·攻1900/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从自己的手卡·卡组·墓地把1只机械族「时间潜行者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成通常怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：有魔法卡和陷阱卡在作为超量素材中的超量怪兽在自己场上存在的场合，把墓地的这张卡除外才能发动。场上1张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上1张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 设置②效果的发动代价为将墓地的此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 发动前确认代价已校验、己方怪兽区有空位，且能按指定属性参数特殊召唤此陷阱怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查己方怪兽区是否至少有1个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方能否将此卡作为念动力族·暗属性·4星·攻1900/守2500的通常陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x126,TYPES_NORMAL_TRAP_MONSTER,1900,2500,4,RACE_PSYCHO,ATTRIBUTE_DARK) end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤可特殊召唤的机械族「时间潜行者」怪兽
function s.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(0x126) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：为自身附加通常怪兽与陷阱属性并表侧特召到怪兽区，随后若满足条件可从手卡·卡组·墓地选1只机械族「时间潜行者」怪兽特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认能否将此卡作为对应属性的通常陷阱怪兽特殊召唤，不能则中止
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x126,TYPES_NORMAL_TRAP_MONSTER,1900,2500,4,RACE_PSYCHO,ATTRIBUTE_DARK) then return end
	local c=e:GetHandler()
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 无视召唤条件将此卡以表侧表示特殊召唤到己方怪兽区，若未成功则中止后续处理
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 受「王家长眠之谷」判定过滤后，从己方卡组·墓地·手卡检索可特召的机械族「时间潜行者」怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
	-- 若己方怪兽区仍有空位且存在可特召怪兽，询问玩家是否再特殊召唤1只
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把怪兽特殊召唤？"
		-- 向己方发送选择要特殊召唤的机械族「时间潜行者」怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 插入效果处理间断，使陷阱怪兽特召与后续机械族「时间潜行者」怪兽特召视为不同时处理
		Duel.BreakEffect()
		-- 将选中的机械族「时间潜行者」怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤己方场上表侧表示、且超量素材中同时包含魔法卡和陷阱卡的超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SPELL)
		and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- 检查②效果发动条件：己方怪兽区是否存在同时拥有魔法卡和陷阱卡作为超量素材的超量怪兽
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方怪兽区是否存在至少1只满足cfilter条件的超量怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动前确认场上至少有1张可除外的卡，并登记除外1张卡的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有可以被除外的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 登记将场上1张卡除外的作用信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果处理：从双方场上选择1张可除外的卡，显示选择提示并将其表侧除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送从场上选择要除外的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让己方从双方场上选择1张可除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 向双方展示被选中除外的卡片动画
		Duel.HintSelection(g)
		-- 将选中的场上卡片以效果表侧除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
