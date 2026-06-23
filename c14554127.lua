--ピース・オブ・スタチュー
-- 效果：
-- ①：这张卡发动后变成持有以下效果的效果怪兽（岩石族·地·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ●自己·对方回合，支付800基本分才能发动（这个卡名的这个效果1回合只能使用1次）。「和平之像」以外的自己的墓地·除外状态的1张永续陷阱卡作为卡名当作「和平之像」使用的通常怪兽（岩石族·地·4星·攻/守1000）特殊召唤（不当作陷阱卡使用）。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①卡发动时的特殊召唤效果和②自己·对方回合的支付LP特殊召唤效果
function s.initial_effect(c)
	-- 将此卡加入代码列表，用于识别同名卡
	aux.AddCodeList(c,id)
	-- 效果①：卡发动时的处理，设置为自由连锁，可特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：自己·对方回合可发动，支付800基本分后特殊召唤墓地或除外的永续陷阱卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果①的发动条件，包括是否有足够怪兽区域和是否可以特殊召唤为效果怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 判断玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤为效果怪兽（岩石族·地·4星·攻/守1800）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数，将此卡变为效果怪兽并特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断玩家是否可以特殊召唤为效果怪兽（岩石族·地·4星·攻/守1800）
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡特殊召唤到场上，作为效果怪兽
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 效果②的支付LP费用处理函数，检查并支付800基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤函数，用于筛选墓地或除外状态的永续陷阱卡
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsFaceupEx()
		-- 判断玩家是否可以特殊召唤为通常怪兽（岩石族·地·4星·攻/守1000）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH)
end
-- 判断是否满足效果②的发动条件，包括是否有足够怪兽区域和是否存在符合条件的永续陷阱卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地或除外区是否存在符合条件的永续陷阱卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1张永续陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的发动处理函数，选择并特殊召唤符合条件的永续陷阱卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断玩家是否可以特殊召唤为通常怪兽（岩石族·地·4星·攻/守1000）
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_EARTH,RACE_ROCK,4,1000,1000)
		-- 将选中的卡的卡号改为和平之像（id），使其当作和平之像使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET)
		e1:SetValue(id)
		tc:RegisterEffect(e1)
		-- 将选中的卡特殊召唤到场上，作为通常怪兽
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
