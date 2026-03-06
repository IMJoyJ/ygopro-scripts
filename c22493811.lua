--アリの増殖
-- 效果：
-- 祭掉自己场上1只昆虫族怪兽发动。在自己场上特殊召唤2只「兵队衍生物」（地·4星·昆虫族·攻500·守1200）。（不能用作上级召唤的祭品）
function c22493811.initial_effect(c)
	-- 效果原文内容：祭掉自己场上1只昆虫族怪兽发动。在自己场上特殊召唤2只「兵队衍生物」（地·4星·昆虫族·攻500·守1200）。（不能用作上级召唤的祭品）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c22493811.cost)
	e1:SetTarget(c22493811.target)
	e1:SetOperation(c22493811.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义了用于判断是否可以作为祭品的昆虫族怪兽的过滤函数
function c22493811.costfilter(c,tp)
	return c:IsRace(RACE_INSECT)
		-- 规则层面作用：检查目标怪兽是否满足祭品条件，包括其所在区域是否还有空位
		and Duel.GetMZoneCount(tp,c)>1 and (c:IsControler(tp) or c:IsFaceup())
end
-- 规则层面作用：设置效果的费用处理函数，用于检查并选择祭品
function c22493811.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 规则层面作用：检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22493811.costfilter,1,nil,tp) end
	-- 规则层面作用：从场上选择满足条件的1张可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c22493811.costfilter,1,1,nil,tp)
	-- 规则层面作用：以REASON_COST原因解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 规则层面作用：设置效果的目标处理函数，用于判断是否可以发动效果
function c22493811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足特殊召唤的条件，包括是否有足够的怪兽区域
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	if chk==0 then
		e:SetLabel(0)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return res and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 规则层面作用：检查玩家是否可以特殊召唤指定的衍生物
			and Duel.IsPlayerCanSpecialSummonMonster(tp,22493812,0,TYPES_TOKEN_MONSTER,500,1200,4,RACE_INSECT,ATTRIBUTE_EARTH)
	end
	-- 规则层面作用：设置操作信息，表示将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 规则层面作用：设置操作信息，表示将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 规则层面作用：设置效果的发动处理函数，用于执行特殊召唤衍生物的操作
function c22493811.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 规则层面作用：检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 规则层面作用：检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22493812,0,TYPES_TOKEN_MONSTER,500,1200,4,RACE_INSECT,ATTRIBUTE_EARTH) then
		for i=1,2 do
			-- 规则层面作用：创建一个指定编号的衍生物
			local token=Duel.CreateToken(tp,22493812)
			-- 规则层面作用：将衍生物特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 效果原文内容：（不能用作上级召唤的祭品）
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 规则层面作用：完成一次特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
