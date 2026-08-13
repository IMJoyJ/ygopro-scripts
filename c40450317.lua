--同胞の絆
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：支付2000基本分，以自己场上1只4星以下的怪兽为对象才能发动。和那只怪兽是卡名不同并是种族·属性·等级相同的2只怪兽从卡组特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
function c40450317.initial_effect(c)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：支付2000基本分，以自己场上1只4星以下的怪兽为对象才能发动。和那只怪兽是卡名不同并是种族·属性·等级相同的2只怪兽从卡组特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c40450317.cost)
	e1:SetTarget(c40450317.target)
	e1:SetOperation(c40450317.activate)
	c:RegisterEffect(e1)
end
-- cost函数：发动前检查能否支付2000LP且本回合未进入过战斗阶段；支付LP，并给自己附加本回合不能进入战斗阶段的誓约效果。
function c40450317.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认玩家可支付2000基本分，且本回合尚未进入过战斗阶段（满足发动条件）。
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 支付2000基本分作为效果发动代价。
	Duel.PayLPCost(tp,2000)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：支付2000基本分，以自己场上1只4星以下的怪兽为对象才能发动。和那只怪兽是卡名不同并是种族·属性·等级相同的2只怪兽从卡组特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进入战斗阶段”的永续效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义对象怪兽的过滤条件：必须表侧表示且等级4以下，并且卡组中存在至少2张满足可特殊召唤条件的同名卡不同的同型怪兽（因此可选出2只）。
function c40450317.filter(c,e,tp)
	if c:IsFacedown() or not c:IsLevelBelow(4) then return false end
	-- 从卡组中筛选出所有与对象怪兽等级、种族、属性相同、卡名不同且可特殊召唤的怪兽，作为可选的候选组。
	local g=Duel.GetMatchingGroup(c40450317.filter2,tp,LOCATION_DECK,0,nil,e,tp,c)
	return g:GetClassCount(Card.GetCode)>1
end
-- 定义候选怪兽的筛选条件：与对象怪兽等级、种族、属性相同，卡名不同，且能够被效果特殊召唤（不检查苏生限制）。
function c40450317.filter2(c,e,tp,tc)
	return c:IsLevel(tc:GetLevel()) and c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute())
		and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数：进行效果发动合法性检查（对象是否存在、格子是否足够、是否受青眼精灵龙限制），并登记选择对象。
function c40450317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40450317.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求自己主要怪兽区至少还有2个空格，否则无法特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认自己场上存在至少1只满足条件的等级4以下表侧怪兽可作为效果对象。
		and Duel.IsExistingTarget(c40450317.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示“请选择效果的对象”的提示信息，引导玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只自己场上符合条件的怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c40450317.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 向系统登记本效果将从卡组特殊召唤2只怪兽的操作信息，供时点检测等机制使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- activate函数（前半）：取得对象并检查条件是否仍成立，若成立则从卡组选出2只卡名不同的同型怪兽特殊召唤。
function c40450317.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 计算自己主要怪兽区当前可用空格数，判断能否容纳2只特殊召唤怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 从卡组中筛选出所有与对象怪兽同等级、同种族、同属性、卡名不同且可特殊召唤的候选怪兽。
	local g=Duel.GetMatchingGroup(c40450317.filter2,tp,LOCATION_DECK,0,nil,e,tp,tc)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ft>1 and g:GetClassCount(Card.GetCode)>1 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 显示“请选择要特殊召唤的卡”的提示，引导玩家选择卡牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从候选中选出2张卡名互不相同的怪兽（同名卡最多1张）。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选出的2只怪兽以表侧攻击表示特殊召唤到自己场上（检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 将“不能特殊召唤怪兽”的自肃效果注册给当前玩家，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
