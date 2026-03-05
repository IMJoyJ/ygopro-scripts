--おジャマデュオ
-- 效果：
-- ①：在对方场上把2只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
-- ②：把墓地的这张卡除外才能发动。从卡组把2只卡名不同的「扰乱」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c14470845.initial_effect(c)
	-- ①：在对方场上把2只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14470845.target)
	e1:SetOperation(c14470845.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把2只卡名不同的「扰乱」怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14470845,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c14470845.sptg)
	e2:SetOperation(c14470845.spop)
	c:RegisterEffect(e2)
end
-- 效果处理函数：c14470845.target，用于判断效果是否可以发动
function c14470845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查对方场上是否有至少2个空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>1
		-- 检查是否可以特殊召唤「扰乱衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置操作信息：将召唤2个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：将特殊召唤2个衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理函数：c14470845.activate，用于执行效果
function c14470845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查对方场上是否有至少2个空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<2 then return end
	-- 检查是否可以特殊召唤「扰乱衍生物」
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,2 do
		-- 创建一张「扰乱衍生物」
		local token=Duel.CreateToken(tp,14470845+i)
		-- 将衍生物特殊召唤到对方场上
		if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
			-- 为衍生物设置效果：不能为上级召唤而解放
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
			-- 为衍生物设置效果：当衍生物被破坏时，其控制者受到每1只300伤害
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_LEAVE_FIELD)
			e2:SetOperation(c14470845.damop)
			token:RegisterEffect(e2,true)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果处理函数：c14470845.damop，用于处理衍生物被破坏时的伤害效果
function c14470845.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 给衍生物的控制者造成300点伤害
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end
-- 过滤函数：c14470845.spfilter，用于筛选可以特殊召唤的「扰乱」怪兽
function c14470845.spfilter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：c14470845.sptg，用于判断效果是否可以发动
function c14470845.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有「扰乱」怪兽
		local g=Duel.GetMatchingGroup(c14470845.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查是否有至少2个空位并确保选出的2只怪兽卡名不同
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and g:GetClassCount(Card.GetCode)>=2 end
	-- 设置操作信息：将特殊召唤2只「扰乱」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数：c14470845.spop，用于执行效果
function c14470845.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取卡组中所有「扰乱」怪兽
	local g=Duel.GetMatchingGroup(c14470845.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检查是否满足发动条件：未受「青眼精灵龙」影响、有足够空位、卡组中有至少2张不同卡名的「扰乱」怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1 and g:GetClassCount(Card.GetCode)>1 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 从符合条件的怪兽中选择2张不同卡名的怪兽
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
