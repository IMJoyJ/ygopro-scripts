--クイーン・バタフライ ダナウス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已通常召唤的场合，以自己墓地最多3只4星以下的昆虫族怪兽为对象才能发动。这张卡的攻击力变成0，作为对象的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：这张卡是已通常召唤的场合，以自己墓地最多3只4星以下的昆虫族怪兽为对象才能发动。这张卡的攻击力变成0，作为对象的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1,id))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件的函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动条件：此卡为通常召唤且不在伤害步骤中
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 筛选可特殊召唤的墓地怪兽的过滤函数
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标的函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	-- 检查是否满足发动条件：此卡攻击力不为0且场上存在空位
	if chk==0 then return aux.nzatk(c) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件：墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 计算可选择的怪兽数量上限
	local ft=math.min(3,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 若受到效果影响则限制为最多1只
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- 执行效果处理的函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsAttack(0) then return end
	-- 将此卡攻击力变为0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- 获取场上空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	-- 获取连锁中已选定的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	-- 若受到效果影响则限制为最多1只
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if #g>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,ft,ft,nil)
	end
	-- 遍历目标怪兽组
	for tc in aux.Next(g) do
		-- 特殊召唤目标怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
