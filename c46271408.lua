--閃刀術式－シザーズクロス
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以自己墓地1只4星「闪刀姬」怪兽为对象才能发动。那只怪兽加入手卡。自己墓地有魔法卡3张以上存在的场合，也能不加入手卡特殊召唤。
function c46271408.initial_effect(c)
	-- 创建效果对象并设置其分类、类型、时点、属性、发动条件、目标选择函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c46271408.condition)
	e1:SetTarget(c46271408.target)
	e1:SetOperation(c46271408.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否有怪兽存在
function c46271408.cfilter(c)
	return c:GetSequence()<5
end
-- 检索函数，用于筛选满足条件的4星闪刀姬怪兽（可加入手牌或特殊召唤）
function c46271408.thfilter(c,e,tp,spchk)
	return c:IsSetCard(0x1115) and c:IsLevel(4) and (c:IsAbleToHand() or (spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果发动条件：自己的主要怪兽区域没有怪兽存在
function c46271408.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有怪兽，则效果可以发动
	return not Duel.IsExistingMatchingCard(c46271408.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标选择函数，判断是否能选择满足条件的墓地怪兽作为对象
function c46271408.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断自己场上是否有可用的怪兽区域
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否有3张以上魔法卡
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46271408.thfilter(chkc,e,tp,spchk) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c46271408.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,spchk) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46271408.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,spchk)
end
-- 效果处理函数，根据条件决定将怪兽加入手牌或特殊召唤
function c46271408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查目标怪兽是否受王家长眠之谷保护
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断自己墓地是否有3张以上魔法卡
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			-- 判断自己场上是否有可用的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 玩家选择是否特殊召唤（选项1190为回手，选项1152为特殊召唤）
			and Duel.SelectOption(tp,1190,1152)==1 then
			-- 将目标怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将目标怪兽加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
