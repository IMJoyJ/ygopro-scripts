--聖蔓の播種
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「圣种」怪兽特殊召唤，自己受到1000伤害。自己场上没有「圣天树」连接怪兽存在的场合，这个效果不是「圣种之地灵」不能特殊召唤。这张卡的发动后，直到回合结束时自己不是植物族怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的植物族连接怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c53286626.initial_effect(c)
	-- 「这个卡名的卡在1回合只能发动1张。①：从卡组把1只「圣种」怪兽特殊召唤，自己受到1000伤害。自己场上没有「圣天树」连接怪兽存在的场合，这个效果不是「圣种之地灵」不能特殊召唤。这张卡的发动后，直到回合结束时自己不是植物族怪兽不能从额外卡组特殊召唤。」
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53286626+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53286626.target)
	e1:SetOperation(c53286626.activate)
	c:RegisterEffect(e1)
	-- 「②：自己场上的植物族连接怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。」
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c53286626.reptg)
	e2:SetValue(c53286626.repval)
	e2:SetOperation(c53286626.repop)
	c:RegisterEffect(e2)
end
-- 过滤可特殊召唤的怪兽：候选卡需为「圣种」字段怪兽且可以被玩家tp效果特殊召唤；check为false（己方场上没有「圣天树」连接怪兽）时，额外限定只能选「圣种之地灵」。
function c53286626.spfilter(c,e,tp,check)
	return c:IsSetCard(0x4158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (check or c:IsCode(27520594))
end
-- 过滤存在性检查用：判断己方场上是否有表侧表示的、属于「圣天树」字段的连接怪兽。
function c53286626.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x2158)
end
-- 发动时的合法判定：chk==0时确认己方主要怪兽区有空位，并且卡组中存在符合spfilter条件的「圣种」怪兽（check决定是否必须为「圣种之地灵」）。
function c53286626.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测己方场上是否存在表侧表示的「圣天树」连接怪兽，将结果存入check，用于后续选择特殊召唤对象时决定检索范围。
	local check=Duel.IsExistingMatchingCard(c53286626.cfilter,tp,LOCATION_MZONE,0,1,nil)
	-- 发动条件之一：己方主要怪兽区必须存在至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：卡组中必须存在满足条件的「圣种」怪兽；若己方场上没有「圣天树」连接怪兽，则必须存在「圣种之地灵」。
		and Duel.IsExistingMatchingCard(c53286626.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check) end
	-- 设置操作信息：本效果涉及从卡组特殊召唤1只怪兽，供其他卡（如星尘龙等）进行效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本效果会给己方玩家造成1000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 处理①：从卡组选1只符合条件的「圣种」怪兽特殊召唤，特殊召唤成功时己方受到1000伤害；之后若本次为魔法卡的发动，则对己方附加直到回合结束不能从额外卡组特殊召唤非植物族怪兽的限制。
function c53286626.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 进行特殊召唤前再次确认己方主要怪兽区仍有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 再次确认己方场上是否有表侧「圣天树」连接怪兽，以决定是否只能选择「圣种之地灵」。
		local check=Duel.IsExistingMatchingCard(c53286626.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选出1张符合条件的「圣种」怪兽；若没有「圣天树」连接怪兽，则只有「圣种之地灵」可选。
		local g=Duel.SelectMatchingCard(tp,c53286626.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
		local tc=g:GetFirst()
		-- 以表侧表示将选中的怪兽特殊召唤到己方场上（使用SpecialSummonStep分步处理，以便与后续伤害联动）。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 特殊召唤成功后，对己方玩家造成1000点效果伤害。
			Duel.Damage(tp,1000,REASON_EFFECT)
		end
		-- 完成特殊召唤处理，触发特殊召唤成功时的相关时点。
		Duel.SpecialSummonComplete()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 「这张卡的发动后，直到回合结束时自己不是植物族怪兽不能从额外卡组特殊召唤。②：自己场上的植物族连接怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。」
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c53286626.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将针对己方玩家的“不能从额外卡组特殊召唤非植物族怪兽”的限制效果注册并适用到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的过滤条件：被检查的卡是从额外卡组特殊召唤的怪兽，且种族不是植物族时，不允许特殊召唤。
function c53286626.splimit(e,c)
	return not c:IsRace(RACE_PLANT) and c:IsLocation(LOCATION_EXTRA)
end
-- ②代替破坏的怪兽条件：己方场上的表侧表示的植物族连接怪兽，且本次破坏原因为战斗或对方的效果（排除代替破坏本身）。
function c53286626.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsRace(RACE_PLANT) and c:IsType(TYPE_LINK)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的发动条件：墓地中的此卡可以除外，且当前存在满足条件的植物族连接怪兽将被破坏；询问玩家是否发动代替破坏。
function c53286626.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c53286626.repfilter,1,nil,tp) end
	-- 让己方玩家选择是否将墓地的此卡除外以代替怪兽被破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏判定函数：判断即将被破坏的怪兽c是否符合“己方场上植物族连接怪兽且被战斗或对方效果破坏”的条件。
function c53286626.repval(e,c)
	return c53286626.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的实际处理：将墓地的此卡除外，代替该植物族连接怪兽被破坏。
function c53286626.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地中的此卡以表侧表示除外，作为代替破坏的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
