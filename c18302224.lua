--リバース・オブ・ネオス
-- 效果：
-- 自己场上表侧表示存在的名字带有「新宇」的融合怪兽被破坏时才能发动。从自己卡组把1只「元素英雄 新宇侠」攻击表示特殊召唤。这个效果特殊召唤的「元素英雄 新宇侠」的攻击力只要在场上表侧表示存在上升1000，这个回合的结束阶段时破坏。
function c18302224.initial_effect(c)
	-- 记录该卡牌效果中涉及的「元素英雄 新宇侠」卡片密码
	aux.AddCodeList(c,89943723)
	-- 为该卡牌添加「新宇」系列编码，用于后续判断是否为「新宇」系列怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- 自己场上表侧表示存在的名字带有「新宇」的融合怪兽被破坏时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c18302224.condition)
	e1:SetTarget(c18302224.target)
	e1:SetOperation(c18302224.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：被破坏的怪兽必须在场上、是自己控制、正面表示、属于「新宇」系列且为融合怪兽
function c18302224.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x9) and c:IsType(TYPE_FUSION)
end
-- 条件判断：确认是否有满足过滤条件的怪兽被破坏
function c18302224.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18302224.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中存在可特殊召唤的「元素英雄 新宇侠」
function c18302224.filter(c,e,tp)
	return c:IsCode(89943723) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 目标设定：检查是否满足特殊召唤条件
function c18302224.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c18302224.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只「元素英雄 新宇侠」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动：检索满足条件的怪兽并特殊召唤
function c18302224.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c18302224.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 使特殊召唤的「元素英雄 新宇侠」攻击力上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 在结束阶段时将该怪兽破坏
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetOperation(c18302224.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 破坏效果处理函数：将自身破坏
function c18302224.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽因效果而破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
