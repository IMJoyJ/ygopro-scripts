--モンスターレリーフ
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。自己场上存在的1只怪兽回到手卡，那之后从手卡把1只4星怪兽特殊召唤。
function c37507488.initial_effect(c)
	-- 创建效果，设置效果分类为回手牌和特殊召唤，类型为发动效果，属性为取对象效果，触发时点为攻击宣言时，条件函数为c37507488.condition，目标函数为c37507488.target，发动函数为c37507488.activate
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
-- 效果发动条件：当前回合玩家不是效果使用者
function c37507488.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是效果使用者
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数：返回可以送入手牌的怪兽，且满足场地上有空位或该怪兽在额外怪兽区
function c37507488.filter(c,ft)
	return c:IsAbleToHand() and (ft>0 or c:GetSequence()<5)
end
-- 设置效果目标：检查自己场上是否存在满足条件的怪兽，并且手牌中存在4星怪兽可以特殊召唤
function c37507488.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取效果使用者场上怪兽区的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37507488.filter(chkc,ft) end
	-- 检查是否满足条件：场上存在满足条件的怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c37507488.filter,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 检查是否满足条件：手牌中存在4星怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(c37507488.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示效果使用者选择要送入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择要送入手牌的怪兽
	local g=Duel.SelectTarget(tp,c37507488.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置操作信息：将选中的怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：从手牌中特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤过滤函数：返回等级为4且可以特殊召唤的怪兽
function c37507488.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动处理：将目标怪兽送入手牌，然后从手牌中特殊召唤一只4星怪兽
function c37507488.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功送入手牌
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		-- 判断目标怪兽是否在手牌中且效果使用者场上存在空位
		and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示效果使用者选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的4星怪兽
		local g=Duel.SelectMatchingCard(tp,c37507488.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的4星怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
