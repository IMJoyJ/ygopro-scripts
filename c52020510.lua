--ダイノルフィア・アラート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把基本分支付一半才能发动。等级合计最多到8星以下为止，从自己墓地选最多2只「恐啡肽狂龙」怪兽特殊召唤。这个回合，自己不是「恐啡肽狂龙」怪兽不能特殊召唤，不能用由这个效果特殊召唤的怪兽攻击宣言。
-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
function c52020510.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把基本分支付一半才能发动。等级合计最多到8星以下为止，从自己墓地选最多2只「恐啡肽狂龙」怪兽特殊召唤。这个回合，自己不是「恐啡肽狂龙」怪兽不能特殊召唤，不能用由这个效果特殊召唤的怪兽攻击宣言。
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
	-- 设置②效果的发动COST为把墓地的这张卡除外，aux.bfgcost负责检查并执行除外。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c52020510.cdop)
	c:RegisterEffect(e2)
end
-- cost函数：效果发动时先检查代价（chk==0时返回true表示可以支付），然后实际支付当前LP的一半（向下取整）作为COST。
function c52020510.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 扣除玩家当前LP的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 筛选墓地中符合条件的怪兽：属于「恐啡肽狂龙」系列、等级8以下、且能被当前效果特殊召唤。
function c52020510.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数：发动时确认能否执行效果——自己主要怪兽区有空位，且墓地存在至少1只符合条件的「恐啡肽狂龙」怪兽。
function c52020510.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足spfilter条件的「恐啡肽狂龙」怪兽。
		and Duel.IsExistingMatchingCard(c52020510.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向系统登记本次效果处理为从墓地特殊召唤，预计最少1只，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- spcheck：检测选中的怪兽组等级合计是否不超过8，用于限制“等级合计最多到8星以下”。
function c52020510.spcheck(g)
	return g:GetSum(Card.GetLevel)<=8
end
-- operation函数：效果处理时，计算可特殊召唤数量（受空格数和青眼精灵龙限制），选择1～2只墓地符合条件的「恐啡肽狂龙」怪兽逐只特殊召唤，并附加“不能攻击”效果；之后为己方附加“本回合不能特殊召唤非「恐啡肽狂龙」怪兽”的自肃。
function c52020510.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算本次最多可特殊召唤的数量：取可用主要怪兽区空格数与2的较小值。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 获取墓地中所有符合条件的「恐啡肽狂龙」怪兽作为可选集合。
	local tg=Duel.GetMatchingGroup(c52020510.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft>0 and #tg>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 弹出提示，要求玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置临时过滤条件：选择的怪兽组等级合计必须不超过8（供SelectSubGroup使用）。
		aux.GCheckAdditional=c52020510.spcheck
		-- 让玩家从可选墓地怪兽中选择1～ft张且等级合计不超过8的「恐啡肽狂龙」怪兽，作为实际特殊召唤对象。
		local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,ft)
		-- 清除临时附加的等级合计条件，避免影响后续其他选择。
		aux.GCheckAdditional=nil
		local tc=g:GetFirst()
		while tc do
			-- 将选中的怪兽逐只以表侧攻击表示特殊召唤（SpecialSummonStep），成功后返回true并继续处理附加效果。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 不能用由这个效果特殊召唤的怪兽攻击宣言。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			tc=g:GetNext()
		end
		-- 完成所有怪兽的特殊召唤，结束SpecialSummonStep分批处理。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不是「恐啡肽狂龙」怪兽不能特殊召唤；②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c52020510.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（不能特殊召唤非「恐啡肽狂龙」怪兽）注册到当前玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- splimit判定：怪兽不属于「恐啡肽狂龙」系列则禁止特殊召唤。
function c52020510.splimit(e,c)
	return not c:IsSetCard(0x173)
end
-- cdcon：②效果的发动条件——自己LP在2000以下，且当前发动的效果来自对方。
function c52020510.cdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己LP是否≤2000，且效果发动方是对方（rp==1-tp）。
	return Duel.GetLP(tp)<=2000 and rp==1-tp
end
-- cdop：②效果处理——给己方注册伤害减免效果，使对方效果造成的对自己的效果伤害变为0，并标记已受保护。
function c52020510.cdop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c52020510.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将EFFECT_CHANGE_DAMAGE效果注册到己方玩家，使对方效果造成的对自己的效果伤害被damval1改写为0。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将EFFECT_NO_EFFECT_DAMAGE效果注册到己方玩家，标记本回合已经受到效果伤害变成0的保护，避免同类效果重复判定。
	Duel.RegisterEffect(e2,tp)
end
-- damval1：如果受到的伤害来自对方玩家的效果伤害（REASON_EFFECT），则把伤害值改为0；否则维持原伤害值。
function c52020510.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
