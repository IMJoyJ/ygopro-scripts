--ガジェット・ボックス
-- 效果：
-- 这个卡名在规则上也当作「变形斗士」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，给这张卡放置3个变形斗士指示物。
-- ②：1回合1次，自己主要阶段才能发动。自己场上1个变形斗士指示物取除，在自己场上把1只「工具箱子衍生物」（机械族·地·1星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
function c8025950.initial_effect(c)
	c:EnableCounterPermit(0x8)
	-- ①：作为这张卡的发动时的效果处理，给这张卡放置3个变形斗士指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,8025950+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c8025950.target)
	e1:SetOperation(c8025950.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己场上1个变形斗士指示物取除，在自己场上把1只「工具箱子衍生物」（机械族·地·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c8025950.sptg)
	e2:SetOperation(c8025950.spop)
	c:RegisterEffect(e2)
end
-- 卡片发动时效果处理的Target函数，用于检测是否能放置指示物并设置操作信息
function c8025950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自身能否放置3个变形斗士指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x8,3,e:GetHandler()) end
	-- 设置操作信息，表示此效果的处理为放置3个变形斗士指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x8)
end
-- 卡片发动时效果处理的Operation函数，在卡片发动成功时给自身放置3个变形斗士指示物
function c8025950.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x8,3)
	end
end
-- 特殊召唤衍生物效果的Target函数，用于检查是否能移去指示物、是否有空怪兽位以及是否能特招衍生物
function c8025950.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己场上是否能移去1个变形斗士指示物，且自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x8,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查玩家是否可以特殊召唤「工具箱子衍生物」（机械族·地·1星·攻/守0）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,8025951,0x51,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置操作信息，表示此效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示此效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的Operation函数，执行移去指示物、特殊召唤衍生物并对玩家施加额外卡组特招限制
function c8025950.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，成功移去自己场上1个变形斗士指示物，且自己场上有空余的怪兽区域
	if Duel.RemoveCounter(tp,1,0,0x8,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且玩家此时仍可以特殊召唤「工具箱子衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,8025951,0x51,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then
		-- 创建「工具箱子衍生物」的卡片数据
		local token=Duel.CreateToken(tp,8025951)
		-- 将衍生物以表侧表示特殊召唤到自己场上（分步特招）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c8025950.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制效果的过滤函数，限制玩家不能从额外卡组特殊召唤同调怪兽以外的怪兽
function c8025950.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
