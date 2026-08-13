--クイーン・バタフライ ダナウス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已通常召唤的场合，以自己墓地最多3只4星以下的昆虫族怪兽为对象才能发动。这张卡的攻击力变成0，作为对象的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：定义其为一回合一次、可在对方回合发动的诱发即时效果，包含攻击力变化和特殊召唤的处理。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡是已通常召唤的场合，以自己墓地最多3只4星以下的昆虫族怪兽为对象才能发动。这张卡的攻击力变成0，作为对象的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果在对方回合也能发动。
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
-- 定义效果的发动条件：此卡已经通过通常召唤出场，且当前并非伤害步骤（或尚未进入伤害计算）。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡的召唤状态为通常召唤，并通过aux.dscon限制在伤害步骤中仅伤害计算前可发动。
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义可选择的墓地怪兽的过滤条件：4星以下、昆虫族、且能够被当前效果特殊召唤。
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果发动时的目标选择：校验对象合法性；在无对象检查中确认此卡攻击力不为0、有可用主怪兽区空位、且墓地存在至少1只满足条件的昆虫族怪兽可供选择。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	-- 无对象检查时需满足此卡当前攻击力不为0，且己方主要怪兽区有空位。
	if chk==0 then return aux.nzatk(c) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 无对象检查时还需墓地存在至少1只可以作为对象的4星以下昆虫族怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 计算可特殊召唤数量上限：最多3只，但不得超过己方主要怪兽区的可用空位数。
	local ft=math.min(3,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1到ft只满足条件的昆虫族怪兽作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置操作信息，告知系统本连锁将进行特殊召唤，对象为选中的这些卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- 效果处理：先确认此卡仍正面且与效果相关且不被免疫且攻击力不为0；将其攻击力暂时设为0；然后筛选仍与效果相关的对象，受青眼精灵龙限制调整可特召数量，逐张表侧特殊召唤，并给它们附加效果无效化，最后完成特殊召唤。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsAttack(0) then return end
	-- 这张卡的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- 获取己方当前可用的主要怪兽区空格数，用于判断和限制特殊召唤数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	-- 从连锁信息中取出发动时选择的对象，并过滤出仍然与当前效果相关的卡片（没有离场或关系重置）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if #g>ft then
		-- 如果对象数量超过可特殊召唤数量限制，弹出选择提示，让玩家从中选择实际要特殊召唤的ft张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 遍历所有最终要特殊召唤的怪兽卡片。
	for tc in aux.Next(g) do
		-- 将当前怪兽以表侧攻击表示特殊召唤到自己场上；不额外检查召唤条件和苏生限制（已在filter中保证）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
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
	-- 完成整个特殊召唤流程，结算所有SpecialSummonStep的怪兽。
	Duel.SpecialSummonComplete()
end
