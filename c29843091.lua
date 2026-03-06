--おジャマトリオ
-- 效果：
-- ①：在对方场上把3只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
function c29843091.initial_effect(c)
	-- 效果设置：将此卡注册为发动时点效果，可特殊召唤衍生物并生成衍生物
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c29843091.target)
	e1:SetOperation(c29843091.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：在对方场上把3只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤
function c29843091.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面：检测对方场上是否有足够的怪兽区域（至少3个空位）
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>2
		-- 规则层面：检测玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) end
	-- 规则层面：设置连锁操作信息，表示将特殊召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 规则层面：设置连锁操作信息，表示将生成3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果执行：检测是否满足发动条件并执行特殊召唤衍生物操作
function c29843091.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 规则层面：检测对方场上是否有足够的怪兽区域（至少3个空位）
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<3 then return end
	-- 规则层面：检测玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,3 do
		-- 规则层面：创建一张指定编号的衍生物卡
		local token=Duel.CreateToken(tp,29843091+i)
		-- 规则层面：尝试特殊召唤一张衍生物卡
		if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
			-- 效果原文：这衍生物不能为上级召唤而解放
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
			-- 效果原文：「扰乱衍生物」被破坏时那控制者受到每1只300伤害
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_LEAVE_FIELD)
			e2:SetOperation(c29843091.damop)
			token:RegisterEffect(e2,true)
		end
	end
	-- 规则层面：完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 效果执行：当衍生物离场时触发的伤害处理函数
function c29843091.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 规则层面：对衍生物的控制者造成300点伤害
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end
