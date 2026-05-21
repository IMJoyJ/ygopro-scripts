--リチュアの写魂鏡
-- 效果：
-- 名字带有「遗式」的仪式怪兽的降临必需。必须支付仪式召唤的怪兽等级×500基本分。
function c9236985.initial_effect(c)
	-- 名字带有「遗式」的仪式怪兽的降临必需。必须支付仪式召唤的怪兽等级×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9236985.target)
	e1:SetOperation(c9236985.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中满足仪式召唤条件且支付得起基本分的「遗式」仪式怪兽
function c9236985.filter(c,e,tp,lp)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x3a)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then return false end
	return lp>c:GetLevel()*500
end
-- 效果发动的目标与合法性检测
function c9236985.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家的生命值
		local lp=Duel.GetLP(tp)
		-- 检查自己场上是否有可用的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手牌中是否存在至少1张满足条件的「遗式」仪式怪兽
			and Duel.IsExistingMatchingCard(c9236985.filter,tp,LOCATION_HAND,0,1,nil,e,tp,lp)
	end
	-- 设置效果处理的操作信息为从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行逻辑
function c9236985.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前玩家的生命值
	local lp=Duel.GetLP(tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足条件的「遗式」仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,c9236985.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lp)
	local tc=tg:GetFirst()
	if tc then
		-- 支付仪式召唤的怪兽等级×500的基本分
		Duel.PayLPCost(tp,tc:GetLevel()*500)
		tc:SetMaterial(nil)
		-- 将该怪兽以仪式召唤的方式表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
