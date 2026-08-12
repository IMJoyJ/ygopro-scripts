--聖蔓の播種
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「圣种」怪兽特殊召唤，自己受到1000伤害。自己场上没有「圣天树」连接怪兽存在的场合，这个效果不是「圣种之地灵」不能特殊召唤。这张卡的发动后，直到回合结束时自己不是植物族怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的植物族连接怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c53286626.initial_effect(c)
	-- ①：从卡组把1只「圣种」怪兽特殊召唤，自己受到1000伤害。自己场上没有「圣天树」连接怪兽存在的场合，这个效果不是「圣种之地灵」不能特殊召唤。这张卡的发动后，直到回合结束时自己不是植物族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53286626+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53286626.target)
	e1:SetOperation(c53286626.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的植物族连接怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c53286626.reptg)
	e2:SetValue(c53286626.repval)
	e2:SetOperation(c53286626.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「圣种」怪兽，包括是否能特殊召唤以及是否为「圣种之地灵」
function c53286626.spfilter(c,e,tp,check)
	return c:IsSetCard(0x4158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (check or c:IsCode(27520594))
end
-- 过滤函数，用于判断场上是否存在「圣天树」连接怪兽
function c53286626.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x2158)
end
-- 效果处理时的判定函数，检查是否有足够的场地和满足条件的卡可以发动此效果
function c53286626.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否存在「圣天树」连接怪兽
	local check=Duel.IsExistingMatchingCard(c53286626.cfilter,tp,LOCATION_MZONE,0,1,nil)
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「圣种」怪兽
		and Duel.IsExistingMatchingCard(c53286626.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check) end
	-- 设置操作信息，表示将要特殊召唤一张来自卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将要对自己造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- 效果发动时执行的操作，包括选择并特殊召唤一只「圣种」怪兽，并对使用者造成1000点伤害，同时注册一个限制植物族以外怪兽从额外卡组特殊召唤的效果
function c53286626.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 检测场上是否存在「圣天树」连接怪兽
		local check=Duel.IsExistingMatchingCard(c53286626.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择一只满足条件的「圣种」怪兽
		local g=Duel.SelectMatchingCard(tp,c53286626.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
		local tc=g:GetFirst()
		-- 尝试特殊召唤所选的怪兽
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 对使用者造成1000点伤害
			Duel.Damage(tp,1000,REASON_EFFECT)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 注册一个限制植物族以外怪兽从额外卡组特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c53286626.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制植物族以外的怪兽从额外卡组特殊召唤
function c53286626.splimit(e,c)
	return not c:IsRace(RACE_PLANT) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，用于判断是否为可被代替破坏的植物族连接怪兽
function c53286626.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsRace(RACE_PLANT) and c:IsType(TYPE_LINK)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标判定函数，检查是否有符合条件的怪兽即将被破坏
function c53286626.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c53286626.repfilter,1,nil,tp) end
	-- 询问玩家是否发动此代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回代替破坏效果的值，表示该怪兽可以被代替破坏
function c53286626.repval(e,c)
	return c53286626.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行函数，将此卡从墓地除外
function c53286626.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从游戏中除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
