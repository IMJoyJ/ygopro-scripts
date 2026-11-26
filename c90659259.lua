--D・コンバートユニット
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽的表示形式的以下效果适用。
-- ●攻击表示：和作为对象的怪兽卡名不同的1只「变形斗士」怪兽从卡组特殊召唤。那之后，作为对象的怪兽回到持有者卡组最上面。
-- ●守备表示：作为对象的怪兽变成攻击表示，从手卡把1只4星以下的机械族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册1回合只能发动1张的通常魔法发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只机械族怪兽为对象才能发动。那只怪兽的表示形式的以下效果适用。●攻击表示：和作为对象的怪兽卡名不同的1只「变形斗士」怪兽从卡组特殊召唤。那之后，作为对象的怪兽回到持有者卡组最上面。●守备表示：作为对象的怪兽变成攻击表示，从手卡把1只4星以下的机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 对象过滤函数：检查是否为表侧表示的机械族怪兽，若为攻击表示需可回卡组且卡组有不同名「变形斗士」可特招，若为守备表示需手卡有4星以下机械族可特招。
function s.tgfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsRace(RACE_MACHINE)) then return false end
	if c:IsAttackPos() then
		return c:IsAbleToDeck()
			-- 检查卡组中是否存在与该怪兽卡名不同且可特殊召唤的「变形斗士」怪兽。
			and Duel.IsExistingMatchingCard(s.atkspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
	else
		-- 检查手卡中是否存在可特殊召唤的4星以下机械族怪兽。
		return Duel.IsExistingMatchingCard(s.defspfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
end
-- 攻击分支特殊召唤过滤函数：检查卡片是否为与目标怪兽卡名不同且可特殊召唤的「变形斗士」怪兽。
function s.atkspfilter(c,e,tp,code)
	return c:IsSetCard(0x26) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 守备分支特殊召唤过滤函数：检查卡片是否为4星以下、机械族且可特殊召唤的怪兽。
function s.defspfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数：校验已选对象的合法性（包括种族和与发动时一致的表示形式）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and chkc:IsFaceup() and chkc:IsRace(RACE_MACHINE) and chkc:IsPosition(e:GetLabel()) end
	-- 发动条件检查：确认自己怪兽区至少有1个空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己场上存在至少1只符合条件的表侧表示机械族怪兽作为对象。
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 发送提示信息，引导玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让己方从自己怪兽区选择1只满足条件的机械族怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetPosition()|POS_FACEUP)
	if tc:IsAttackPos() then
		-- 当对象为攻击表示时，设置预计将对象怪兽返回卡组的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 当对象为攻击表示时，设置预计从自己卡组特殊召唤1只怪兽的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		-- 当对象为守备表示时，设置预计改变对象怪兽表示形式的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
		-- 当对象为守备表示时，设置预计从自己手卡特殊召唤1只怪兽的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
-- ①效果的处理函数：根据对象怪兽的表示形式分别执行卡组特招「变形斗士」并回卡组顶，或转为攻击表示并从手卡特招4星以下机械族怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsAttackPos() and tc:IsFaceup()
		-- 当对象为表侧攻击表示时，检查自己怪兽区是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己卡组选择1只与对象怪兽卡名不同的「变形斗士」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.atkspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
			-- 将所选「变形斗士」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			-- 手动洗切己方的卡组。
			Duel.ShuffleDeck(tp)
			-- 中断当前效果处理，使之后的回卡组顶与之前的特殊召唤视为不同时处理。
			Duel.BreakEffect()
			-- 将对象怪兽以效果返回持有者卡组最上面。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	-- 若对象为守备表示，将其变更为表侧攻击表示并判断是否变更成功。
	elseif tc:IsDefensePos() and Duel.ChangePosition(tc,POS_FACEUP_ATTACK)~=0
		-- 检查自己怪兽区是否有空位用于从手卡特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手卡选择1只4星以下的机械族怪兽。
		local g2=Duel.SelectMatchingCard(tp,s.defspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 将所选的4星以下机械族怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
