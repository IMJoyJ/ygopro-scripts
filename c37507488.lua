--モンスターレリーフ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。自己场上存在的1只怪兽回到手卡，那之后从手卡把1只4星怪兽特殊召唤。
function c37507488.initial_effect(c)
	-- 对应效果原文：“对方怪兽的攻击宣言时才能发动。自己场上存在的1只怪兽回到手卡，那之后从手卡把1只4星怪兽特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c37507488.condition)
	e1:SetTarget(c37507488.target)
	e1:SetOperation(c37507488.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：判断当前是否为对方回合，确保是在对方怪兽攻击宣言时才能发动的场合。
function c37507488.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为己方玩家的对方（即对方回合），满足“对方怪兽的攻击宣言时”的时机前提。
	return Duel.GetTurnPlayer()==1-tp
end
-- 定义回手怪兽的筛选函数：要求该怪兽能被送回手牌，并且若自己主要怪兽区没有空位，则只能是主要怪兽区的怪兽（为后续特殊召唤腾出格子）。
function c37507488.filter(c,ft)
	return c:IsAbleToHand() and (ft>0 or c:GetSequence()<5)
end
-- 定义效果发动时的目标选择与合法性检查函数：计算可用格子，确认能选择己方场上1只怪兽回手，且手牌存在4星可特殊召唤的怪兽，然后选择目标并设置操作信息。
function c37507488.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己主要怪兽区的可用空格数量，用于判断回手后是否有位置特殊召唤以及选择目标的限制。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37507488.filter(chkc,ft) end
	-- 非效果处理时的合法性检查：确认存在至少1只满足条件的己方场上怪兽可以作为对象（同时保证回手后至少有空格）。
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c37507488.filter,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 并检查手牌中是否存在1只4星且可以特殊召唤的怪兽，保证后续处理必定能进行。
		and Duel.IsExistingMatchingCard(c37507488.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向玩家给出选择提示，要求选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1只满足条件的怪兽作为效果的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c37507488.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置操作信息：将所选择的怪兽以效果原因送回手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：后续效果处理时将从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义特殊召唤怪兽的筛选函数：要求是等级4，并且当前能被玩家以效果特殊召唤。
function c37507488.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理函数：先将对象怪兽送回手牌，若成功且手牌存在4星怪兽、自己场上有空位，则选择1只4星怪兽特殊召唤。
function c37507488.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时仍然关联的（此前选择作为对象的）怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽仍与该效果关联，并且将其送回手牌的操作成功（返回值大于0）。
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		-- 确认该怪兽已到持有者手牌，且我方主要怪兽区有空位可供后续特殊召唤。
		and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家给出选择提示，要求选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足等级4且可特殊召唤条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,c37507488.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
