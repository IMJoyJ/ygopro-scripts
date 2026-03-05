--フォトン・サンクチュアリ
-- 效果：
-- 这张卡发动的回合，自己不是光属性怪兽不能召唤·反转召唤·特殊召唤。
-- ①：在自己场上把2只「光子衍生物」（雷族·光·4星·攻2000/守0）守备表示特殊召唤。这衍生物不能攻击，也不能作为同调素材。
function c17418744.initial_effect(c)
	-- 创建并注册卡牌效果，使此卡成为发动时点为自由连锁的魔法卡，具有特殊召唤、cost、target和activate功能
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17418744.cost)
	e1:SetTarget(c17418744.target)
	e1:SetOperation(c17418744.activate)
	c:RegisterEffect(e1)
	-- 设置召唤次数计数器，用于记录玩家在回合内是否进行过召唤操作
	Duel.AddCustomActivityCounter(17418744,ACTIVITY_SUMMON,c17418744.counterfilter)
	-- 设置特殊召唤次数计数器，用于记录玩家在回合内是否进行过特殊召唤操作
	Duel.AddCustomActivityCounter(17418744,ACTIVITY_SPSUMMON,c17418744.counterfilter)
	-- 设置反转召唤次数计数器，用于记录玩家在回合内是否进行过反转召唤操作
	Duel.AddCustomActivityCounter(17418744,ACTIVITY_FLIPSUMMON,c17418744.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为光属性
function c17418744.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- cost函数中检查玩家在本回合是否进行过召唤、特殊召唤或反转召唤操作
function c17418744.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在本回合是否进行过召唤操作
	if chk==0 then return Duel.GetCustomActivityCount(17418744,tp,ACTIVITY_SUMMON)==0
		-- 检查玩家在本回合是否进行过特殊召唤操作
		and Duel.GetCustomActivityCount(17418744,tp,ACTIVITY_SPSUMMON)==0
		-- 检查玩家在本回合是否进行过反转召唤操作
		and Duel.GetCustomActivityCount(17418744,tp,ACTIVITY_FLIPSUMMON)==0 end
	-- 创建并注册禁止特殊召唤的效果，使玩家在本回合不能特殊召唤非光属性怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17418744.sumlimit)
	-- 将禁止特殊召唤效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将禁止通常召唤效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 将禁止反转召唤效果注册给玩家
	Duel.RegisterEffect(e3,tp)
end
-- sumlimit函数，用于判断怪兽是否为非光属性（0x6f为非光属性）
function c17418744.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsAttribute(0x6f)
end
-- target函数中检查玩家是否未受青眼精灵龙效果影响，并且场上空位足够且可以特殊召唤衍生物
function c17418744.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤光子衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17418745,0x55,TYPES_TOKEN_MONSTER,2000,0,4,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示本次连锁将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示本次连锁将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- activate函数中检查玩家是否未受青眼精灵龙效果影响，并且场上空位足够且可以特殊召唤衍生物
function c17418744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有足够的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤光子衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17418745,0x55,TYPES_TOKEN_MONSTER,2000,0,4,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) then
		for i=1,2 do
			-- 创建一张光子衍生物
			local token=Duel.CreateToken(tp,17418745)
			-- 将光子衍生物以守备表示特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 为光子衍生物添加不能攻击的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 为光子衍生物添加不能作为同调素材的效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤流程，结束本次特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
