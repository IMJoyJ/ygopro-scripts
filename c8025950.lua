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
	-- ②：1回合1次，自己主要阶段才能发动。自己场上1个变形斗士指示物取除，在自己场上把1只「工具箱子衍生物」（机械族·地·1星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c8025950.sptg)
	e2:SetOperation(c8025950.spop)
	c:RegisterEffect(e2)
end
c8025950.mentioned_counter={
	[0x8]=true,
}
-- ①效果发动准备：检查此卡能否放置指示物，并设置放置3个变形斗士指示物的操作信息
function c8025950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否可以放置3个变形斗士指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x8,3,e:GetHandler()) end
	-- 设置连锁操作信息：放置3个变形斗士指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x8)
end
-- ①效果处理：给这张卡放置3个变形斗士指示物
function c8025950.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x8,3)
	end
end
-- ②效果发动准备检查：检查能否取除指示物、怪兽区是否有空位及能否生成衍生物
function c8025950.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能取除1个变形斗士指示物且怪兽区是否有可用空格
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x8,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能在自己场上特殊召唤「工具箱子衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,8025951,0x51,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息：生成1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：取除1个变形斗士指示物，特殊召唤1只「工具箱子衍生物」，并为其赋予从额外卡组特召受限的永续效果
function c8025950.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取除自己场上1个变形斗士指示物并判断怪兽区是否有空格
	if Duel.RemoveCounter(tp,1,0,0x8,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤「工具箱子衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,8025951,0x51,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then
		-- 创建「工具箱子衍生物」卡片实例
		local token=Duel.CreateToken(tp,8025951)
		-- 分步处理：将衍生物表侧表示特殊召唤
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
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 额外特召限制过滤：非同调怪兽且来自额外卡组
function c8025950.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
