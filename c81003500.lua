--E・HERO ネクロイド・シャーマン
-- 效果：
-- 「元素英雄 荒野侠」＋「元素英雄 死灵暗侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。那之后，从对方墓地选1只怪兽在对方场上特殊召唤。
function c81003500.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「元素英雄 荒野侠」和「元素英雄 死灵暗侠」的融合召唤手续
	aux.AddFusionProcCode2(c,86188410,89252153,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。那之后，从对方墓地选1只怪兽在对方场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81003500,0))  --"破坏并特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c81003500.target)
	e2:SetOperation(c81003500.operation)
	c:RegisterEffect(e2)
end
c81003500.material_setcode=0x8
-- 效果①的发动准备阶段，检查并选择对方场上的1只怪兽作为对象，并声明破坏与特殊召唤的操作信息
function c81003500.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置当前连锁的操作信息为从对方墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end
-- 过滤函数：筛选对方墓地中可以由我方选择并在对方场上以表侧表示特殊召唤的怪兽
function c81003500.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果①的处理阶段，破坏作为对象的怪兽，并在对方场上特殊召唤对方墓地的一只怪兽
function c81003500.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽存在且仍与效果相关，则将其因效果破坏，并判断是否破坏成功
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断效果处理，使后续的特殊召唤处理与破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 检查对方场上是否有可用的怪兽区域
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从对方墓地选择1只满足特殊召唤条件的怪兽
			local sg=Duel.SelectMatchingCard(tp,c81003500.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 将选中的怪兽在对方场上以表侧表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
end
