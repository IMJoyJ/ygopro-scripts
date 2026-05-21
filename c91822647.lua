--ガスタのつむじ風
-- 效果：
-- 自己场上没有怪兽存在的场合才能发动。选择自己墓地存在的2只名字带有「薰风」的怪兽回到卡组。那之后，从自己卡组把1只守备力1000以下的名字带有「薰风」的怪兽特殊召唤。
function c91822647.initial_effect(c)
	-- 自己场上没有怪兽存在的场合才能发动。选择自己墓地存在的2只名字带有「薰风」的怪兽回到卡组。那之后，从自己卡组把1只守备力1000以下的名字带有「薰风」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c91822647.condition)
	e1:SetTarget(c91822647.target)
	e1:SetOperation(c91822647.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：自己场上没有怪兽存在
function c91822647.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件1：墓地中名字带有「薰风」的怪兽且能回到卡组
function c91822647.filter1(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤条件2：卡组中名字带有「薰风」且守备力1000以下、能特殊召唤的怪兽
function c91822647.filter2(c,e,tp)
	return c:IsSetCard(0x10) and c:IsDefenseBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查函数
function c91822647.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2只满足过滤条件1的「薰风」怪兽作为效果对象
		and Duel.IsExistingTarget(c91822647.filter1,tp,LOCATION_GRAVE,0,2,nil)
		-- 检查自己卡组是否存在至少1只满足过滤条件2的「薰风」怪兽
		and Duel.IsExistingMatchingCard(c91822647.filter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2只满足条件的「薰风」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91822647.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置当前连锁的操作信息：将选中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置当前连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（发动）函数
function c91822647.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==2 then
		-- 将作为对象的怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「薰风」怪兽
		local sg=Duel.SelectMatchingCard(tp,c91822647.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 中断当前效果，使后续的特殊召唤处理与返回卡组处理不视为同时进行
			Duel.BreakEffect()
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
