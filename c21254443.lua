--星遺物の導き
-- 效果：
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「星遗物」怪兽除外，以自己墓地2只怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c21254443.initial_effect(c)
	-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「星遗物」怪兽除外，以自己墓地2只怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c21254443.cost)
	e1:SetTarget(c21254443.target)
	e1:SetOperation(c21254443.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测满足条件的「星遗物」怪兽（手牌或场上正面表示）
function c21254443.cfilter(c,ft)
	return c:IsSetCard(0xfe) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and (ft>0 or c:IsLocation(LOCATION_MZONE))
end
-- 支付效果代价：选择1只「星遗物」怪兽除外
function c21254443.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足支付代价的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21254443.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只「星遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c21254443.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的怪兽除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检测可以特殊召唤的怪兽
function c21254443.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择2只墓地怪兽作为特殊召唤对象
function c21254443.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21254443.filter(chkc,e,tp) end
	-- 检查是否满足发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查是否满足发动条件：墓地存在2只可特殊召唤的怪兽
		and Duel.IsExistingTarget(c21254443.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2只墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c21254443.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置连锁操作信息：准备特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果发动处理：执行特殊召唤并设置不能攻击效果
function c21254443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中已选择的目标卡组并筛选与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 给特殊召唤的怪兽设置不能攻击的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
