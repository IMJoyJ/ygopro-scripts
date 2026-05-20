--ウィッシュ・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。在自己场上把2只「龙衍生物」（龙族·地·1星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是5星以上的龙族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义①号效果为场上发动的起动效果，限制每回合只能使用1次，并设置对应的Cost、Target和Operation。
function s.initial_effect(c)
	-- ①：把这张卡解放才能发动。在自己场上把2只「龙衍生物」（龙族·地·1星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是5星以上的龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 效果发动的代价（Cost）判定与执行函数，检查自身是否可以解放并将其解放。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 将自身解放作为发动的代价。
	Duel.Release(c,REASON_COST)
end
-- 效果发动的目标（Target）判定函数，检查是否满足不受到青眼精灵龙限制、自身解放后有2个以上的怪兽区域空位，且可以特殊召唤衍生物。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查在自身解放离开场上后，自己场上是否有2个以上的怪兽区域空位。
		and Duel.GetMZoneCount(tp,e:GetHandler())>=2
		-- 检查玩家是否可以特殊召唤1星、地属性、龙族、攻守为0的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_EARTH) end
	-- 设置连锁信息，表示该效果包含产生2只衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁信息，表示该效果包含特殊召唤2只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 限制特殊召唤的过滤函数，判定特殊召唤的怪兽是否不是5星以上的龙族怪兽且来自额外卡组。
function s.splimit(e,c)
	return not (c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON)) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果处理（Operation）函数，注册“不能从额外卡组特殊召唤5星以上龙族以外的怪兽”的玩家限制效果，并在满足条件时特殊召唤2只「龙衍生物」。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 在自己场上把2只「龙衍生物」（龙族·地·1星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是5星以上的龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤5星以上龙族以外怪兽的限制效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查当前自己场上的主要怪兽区域空位数是否大于1。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查当前是否仍可以特殊召唤该衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_EARTH) then
		for i=1,2 do
			-- 在后台创建「龙衍生物」的卡片数据。
			local token=Duel.CreateToken(tp,id+o)
			-- 逐步将衍生物以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤的流程，处理相关的特殊召唤成功时时点。
		Duel.SpecialSummonComplete()
	end
end
