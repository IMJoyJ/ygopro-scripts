--トランシケーダ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。在自己场上把1只「蝉蜕衍生物」（昆虫族·地·3星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物在怪兽区域存在，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
function c1799464.initial_effect(c)
	-- 创建效果1，用于处理脱壳蝉特殊召唤成功时的诱发效果，设置其为单体诱发效果，触发事件是特殊召唤成功，限制每回合只能发动一次，目标函数为sptg，处理函数为spop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1799464,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1799464)
	e1:SetTarget(c1799464.sptg)
	e1:SetOperation(c1799464.spop)
	c:RegisterEffect(e1)
end
-- 判断是否满足特殊召唤衍生物的条件，包括场上是否有空位以及是否可以特殊召唤指定的衍生物
function c1799464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1799465,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示将要特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将要特殊召唤1个衍生物（重复设置）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理特殊召唤衍生物的效果，包括创建衍生物、特殊召唤、设置限制效果
function c1799464.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1799465,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_INSECT,ATTRIBUTE_EARTH) then
		-- 创建编号为1799465的衍生物（蝉蜕衍生物）
		local token=Duel.CreateToken(tp,1799465)
		-- 将创建的衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 为衍生物创建一个永续效果，限制玩家不能从额外卡组特殊召唤非昆虫族怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c1799464.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤流程，确保所有特殊召唤操作完成
		Duel.SpecialSummonComplete()
	end
end
-- 限制效果的目标函数，判断目标怪兽是否为非昆虫族且位于额外卡组
function c1799464.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
