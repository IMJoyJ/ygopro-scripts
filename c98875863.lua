--Gゴーレム・ロックハンマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡丢弃1只其他的电子界族怪兽才能发动。这个回合，这张卡的等级下降2星。
-- ②：把这张卡解放才能发动。在自己场上把3只「G石人衍生物」（电子界族·地·1星·攻/守0）守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
function c98875863.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从手卡丢弃1只其他的电子界族怪兽才能发动。这个回合，这张卡的等级下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98875863,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98875863)
	e1:SetCost(c98875863.lvcost)
	e1:SetTarget(c98875863.lvtg)
	e1:SetOperation(c98875863.lvop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。在自己场上把3只「G石人衍生物」（电子界族·地·1星·攻/守0）守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98875863,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,98875864)
	e2:SetCost(c98875863.tkcost)
	e2:SetTarget(c98875863.tktg)
	e2:SetOperation(c98875863.tkop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除自身以外的电子界族怪兽
function c98875863.lvcfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- 效果①的发动代价：从手卡丢弃1只其他的电子界族怪兽
function c98875863.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98875863.lvcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手卡中1只其他的电子界族怪兽丢弃
	Duel.DiscardHand(tp,c98875863.lvcfilter,1,1,REASON_DISCARD+REASON_COST,e:GetHandler())
end
-- 效果①的发动准备：检查这张卡的等级是否在3星以上
function c98875863.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(3) end
end
-- 效果①的处理：使这张卡的等级下降2星
function c98875863.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡的等级下降2星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动代价：把这张卡解放
function c98875863.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备：检查是否能特殊召唤3只衍生物
function c98875863.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查这张卡解放后，自己场上是否有3个以上的空怪兽区域
		and Duel.GetMZoneCount(tp,e:GetHandler())>2
		-- 检查玩家是否能特殊召唤3只「G石人衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,98875864,0x186,TYPES_TOKEN_MONSTER,0,0,3,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤3只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
	-- 设置产生3只衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
end
-- 效果②的处理：特殊召唤3只「G石人衍生物」，并适用特殊召唤限制
function c98875863.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查是否能特殊召唤「G石人衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,98875864,0x186,TYPES_TOKEN_MONSTER,0,0,3,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		local ct=3
		while ct>0 do
			-- 创建「G石人衍生物」卡片数据
			local token=Duel.CreateToken(tp,98875864)
			-- 将衍生物以表侧守备表示特殊召唤到场上（分步处理）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			ct=ct-1
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c98875863.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤电子界族以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤电子界族怪兽
function c98875863.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
