--ダイノルフィア・アラート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把基本分支付一半才能发动。等级合计最多到8星以下为止，从自己墓地选最多2只「恐啡肽狂龙」怪兽特殊召唤。这个回合，自己不是「恐啡肽狂龙」怪兽不能特殊召唤，不能用由这个效果特殊召唤的怪兽攻击宣言。
-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
function c52020510.initial_effect(c)
	-- ①：把基本分支付一半才能发动。等级合计最多到8星以下为止，从自己墓地选最多2只「恐啡肽狂龙」怪兽特殊召唤。这个回合，自己不是「恐啡肽狂龙」怪兽不能特殊召唤，不能用由这个效果特殊召唤的怪兽攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,52020510+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c52020510.cost)
	e1:SetTarget(c52020510.target)
	e1:SetOperation(c52020510.operation)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c52020510.cdcon)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c52020510.cdop)
	c:RegisterEffect(e2)
end
-- 支付一半基本分作为发动cost
function c52020510.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分作为发动cost
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤满足「恐啡肽狂龙」且等级不超过8的怪兽
function c52020510.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的处理目标为从墓地特殊召唤
function c52020510.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c52020510.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 检查所选怪兽等级总和是否不超过8
function c52020510.spcheck(g)
	return g:GetSum(Card.GetLevel)<=8
end
-- 处理特殊召唤效果，包括选择怪兽、特殊召唤并设置不能攻击效果
function c52020510.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算最多可特殊召唤的怪兽数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 获取满足条件的墓地怪兽组
	local tg=Duel.GetMatchingGroup(c52020510.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft>0 and #tg>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置额外检查条件为等级总和不超过8
		aux.GCheckAdditional=c52020510.spcheck
		-- 从符合条件的怪兽中选择最多ft只组成子集
		local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
		-- 清除额外检查条件
		aux.GCheckAdditional=nil
		local tc=g:GetFirst()
		while tc do
			-- 尝试特殊召唤单张怪兽
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 给特殊召唤的怪兽添加不能攻击的效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			tc=g:GetNext()
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
	-- 设置永续效果，禁止在本回合特殊召唤非恐啡肽狂龙怪兽
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c52020510.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制非恐啡肽狂龙怪兽的特殊召唤
function c52020510.splimit(e,c)
	return not c:IsSetCard(0x173)
end
-- 判断发动条件：自己基本分≤2000且为对方发动效果
function c52020510.cdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动条件：自己基本分≤2000且为对方发动效果
	return Duel.GetLP(tp)<=2000 and rp==1-tp
end
-- 处理效果伤害变更和无效化
function c52020510.cdop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果伤害归零的处理
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c52020510.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册伤害变更效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册伤害无效效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否为效果伤害且为对方造成的伤害
function c52020510.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
