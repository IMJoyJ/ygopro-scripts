--ヴァンパイア・グリムゾン
-- 效果：
-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，可以作为代替而支付那些破坏的怪兽数量×1000基本分。
-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
function c33438666.initial_effect(c)
	-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，可以作为代替而支付那些破坏的怪兽数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c33438666.reptg)
	e1:SetValue(c33438666.repval)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c33438666.regop)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33438666,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c33438666.spcon)
	e3:SetTarget(c33438666.sptg)
	e3:SetOperation(c33438666.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的被破坏怪兽：必须是表侧表示、控制者为自己、在自己场上、被战斗或对方效果破坏、且不是代替破坏
function c33438666.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and not c:IsReason(REASON_REPLACE)
end
-- 处理代替破坏效果：计算满足条件的怪兽数量，检查是否能支付相应LP，若能则选择是否发动
function c33438666.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c33438666.repfilter,nil,tp)
	-- 检查是否能支付破坏怪兽数量×1000的LP
	if chk==0 then return ct>0 and Duel.CheckLPCost(tp,1000*ct) end
	-- 提示玩家选择是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 支付破坏怪兽数量×1000的LP
		Duel.PayLPCost(tp,1000*ct)
		return true
	else return false end
end
-- 设置代替破坏效果的返回值为满足条件的怪兽
function c33438666.repval(e,c)
	return c33438666.repfilter(c,e:GetHandlerPlayer())
end
-- 注册战斗破坏标志，用于后续判断是否能发动效果
function c33438666.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(33438666,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判断是否已注册战斗破坏标志，决定是否能发动效果
function c33438666.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(33438666)~=0
end
-- 过滤满足条件的墓地怪兽：必须是战斗破坏、破坏者为当前卡、回合ID匹配、可特殊召唤
function c33438666.spfilter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件：检查场上是否有空位且墓地存在满足条件的怪兽
function c33438666.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c33438666.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c33438666.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 设置操作信息：确定要特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果：获取场上空位数，检测青眼精灵龙限制，选择并特殊召唤怪兽
function c33438666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取满足条件的墓地怪兽组（排除受王家长眠之谷影响的怪兽）
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c33438666.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
