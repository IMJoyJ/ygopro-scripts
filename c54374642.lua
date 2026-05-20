--Ai－SHOW
-- 效果：
-- ①：额外怪兽区域有自己的连接3以上的「@火灵天星」怪兽存在的场合，对方怪兽的攻击宣言时才能发动。攻击力合计最多到那只攻击怪兽的攻击力以下为止，选连接怪兽以外的攻击力2300的电子界族怪兽任意数量从额外卡组特殊召唤。那之后，战斗阶段结束。
function c54374642.initial_effect(c)
	-- ①：额外怪兽区域有自己的连接3以上的「@火灵天星」怪兽存在的场合，对方怪兽的攻击宣言时才能发动。攻击力合计最多到那只攻击怪兽的攻击力以下为止，选连接怪兽以外的攻击力2300的电子界族怪兽任意数量从额外卡组特殊召唤。那之后，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c54374642.condition)
	e1:SetTarget(c54374642.target)
	e1:SetOperation(c54374642.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示、属于「@火灵天星」系列、连接3以上且位于额外怪兽区域的怪兽
function c54374642.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135) and c:IsLinkAbove(3) and c:GetSequence()>=5
end
-- 发动条件：检查自己场上是否存在满足条件的「@火灵天星」怪兽
function c54374642.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（包括额外怪兽区域）是否存在至少1张满足条件的「@火灵天星」怪兽
	return Duel.IsExistingMatchingCard(c54374642.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：额外卡组中可以特殊召唤的、连接怪兽以外的、攻击力为2300的电子界族怪兽
function c54374642.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and not c:IsType(TYPE_LINK) and c:IsAttack(2300)
		-- 检查该卡是否可以特殊召唤，且额外卡组怪兽出场所需的怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标选择与检测：确认攻击怪兽是对方怪兽且攻击力在2300以上，且自己额外卡组有可特召的怪兽
function c54374642.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前进行攻击宣言的怪兽
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsControler(1-tp) and tc:IsAttackAbove(2300)
		-- 检查额外卡组是否存在至少1张满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c54374642.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 将攻击怪兽设为效果处理的对象
	Duel.SetTargetCard(tc)
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：额外卡组中里侧表示的融合、同调、超量怪兽
function c54374642.exfilter1(c)
	return c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤条件：额外卡组中表侧表示的灵摆怪兽
function c54374642.exfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 组合选择过滤函数：限制选择的怪兽数量不超过可用怪兽区域和特召限制，且攻击力合计不超过攻击怪兽的攻击力
function c54374642.fselect(g,ft1,ft2,ect,ft,atk)
	return #g<=ft and #g<=ect
		and g:FilterCount(c54374642.exfilter1,nil)<=ft1
		and g:FilterCount(c54374642.exfilter2,nil)<=ft2
		and g:GetSum(Card.GetAttack)<=atk
end
-- 效果处理：计算可用区域，选择并特殊召唤任意数量满足条件的怪兽，之后结束战斗阶段
function c54374642.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前设为对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsAttackAbove(2300) then return end
	-- 获取额外卡组中所有满足特殊召唤条件的怪兽
	local g=Duel.GetMatchingGroup(c54374642.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g==0 then return end
	-- 计算额外卡组中里侧怪兽（融合/同调/超量）可特殊召唤的怪兽区域数量
	local ft1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 计算额外卡组中表侧灵摆怪兽可特殊召唤的怪兽区域数量
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 获取自己场上可用的怪兽区域总数
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft>0 then ft=1 end
	end
	-- 考虑特定卡片（如其他限制特召数量的效果）影响后的实际可用怪兽区域数量
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	if ect==0 or ft1==0 and ft2==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c54374642.fselect,false,1,ft,ft1,ft2,ect,ft,tc:GetAttack())
	-- 将选中的怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续的“战斗阶段结束”处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段，使其直接进入结束步骤，从而结束战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
