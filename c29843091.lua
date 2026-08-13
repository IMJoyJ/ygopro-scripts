--おジャマトリオ
-- 效果：
-- ①：在对方场上把3只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
function c29843091.initial_effect(c)
	-- ①：在对方场上把3只「扰乱衍生物」（兽族·光·2星·攻0/守1000）守备表示特殊召唤。这衍生物不能为上级召唤而解放。「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c29843091.target)
	e1:SetOperation(c29843091.activate)
	c:RegisterEffect(e1)
end
-- 发动效果前的合法性判断：确认青眼精灵龙的效果没有适用（不禁止同时特殊召唤2只以上）、对方怪兽区至少有空位、且自己可以特殊召唤「扰乱衍生物」到对方场上。
function c29843091.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查对方主要怪兽区可用空位是否大于2（即至少存在3个空位用于特殊召唤3只衍生物）。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>2
		-- 检查当前玩家能否将3只「扰乱衍生物」（兽族·光·2星·攻0/守1000）以表侧守备表示特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置本次连锁的操作信息：包括生成衍生物，预定数量为3。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置本次连锁的操作信息：包括特殊召唤操作，预定数量为3。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理：再次确认青眼精灵龙效果不适用、对方怪兽区至少3个空位且能够特殊召唤衍生物；然后依次创建3只衍生物特殊召唤到对方场上，并为每只衍生物注册‘不能上级召唤解放’和‘被破坏时造成伤害’的效果。
function c29843091.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查对方场上可用怪兽区至少3个，不满足则终止处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<3 then return end
	-- 效果处理时再次确认满足特殊召唤「扰乱衍生物」的条件，不满足则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN_MONSTER,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,3 do
		-- 创建1只「扰乱衍生物」衍生物（卡号29843092，对应token），由“扰乱三人组”的效果特殊召唤。
		local token=Duel.CreateToken(tp,29843091+i)
		-- 将衍生物以表侧守备表示特殊召唤到对方场上（tp的对方），若特殊召唤成功则继续为衍生物注册效果。
		if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这衍生物不能为上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			token:RegisterEffect(e1,true)
			-- 「扰乱衍生物」被破坏时那控制者受到每1只300伤害。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_LEAVE_FIELD)
			e2:SetOperation(c29843091.damop)
			token:RegisterEffect(e2,true)
		end
	end
	-- 完成所有衍生物的特殊召唤流程，触发特殊召唤成功的时点。
	Duel.SpecialSummonComplete()
end
-- 衍生物离场时的诱发效果：若该衍生物是被破坏离场，则给其破坏前的控制者造成300点伤害；之后重置该效果。
function c29843091.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 给予该衍生物破坏前控制者300点效果伤害。
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end
