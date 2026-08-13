--ナイトメア・デーモンズ
-- 效果：
-- ①：把自己场上1只怪兽解放才能发动。在对方场上把3只「梦魇恶魔衍生物」（恶魔族·暗·6星·攻/守2000）攻击表示特殊召唤。「梦魇恶魔衍生物」被破坏时那控制者受到每1只800伤害。
function c42956963.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。在对方场上把3只「梦魇恶魔衍生物」（恶魔族·暗·6星·攻/守2000）攻击表示特殊召唤。「梦魇恶魔衍生物」被破坏时那控制者受到每1只800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42956963.cost)
	e1:SetTarget(c42956963.target)
	e1:SetOperation(c42956963.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：先检查自己场上有至少1只可解放的怪兽，然后选择1只怪兽解放作为COST。
function c42956963.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己场上存在至少1只可解放的怪兽，否则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择解放对象：让自己从自己场上选择1只可解放的怪兽作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽以COST形式解放。
	Duel.Release(g,REASON_COST)
end
-- 效果发动条件判定：检查青眼精灵龙的效果未生效、对方主要怪兽区空位大于2、且自己能将梦魇恶魔衍生物特殊召唤到对方场上，满足时效果才能发动。
function c42956963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查对方场上的主要怪兽区空格数是否大于2，即至少需要3个空位用于特殊召唤3只衍生物。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>2
		-- 检查自己能否以表侧攻击表示在对方场上特殊召唤梦魇恶魔衍生物（暗属性·恶魔族·6星·攻/守2000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,42956964,0x45,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) end
	-- 登记操作信息：本效果将生成3只衍生物，供连锁判定与时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 登记操作信息：本效果将特殊召唤3只怪兽，供连锁判定与时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理：先再次确认青眼精灵龙效果未生效、对方场上仍有足够空位且自己仍可特殊召唤衍生物；然后循环3次创建并特殊召唤梦魇恶魔衍生物到对方场上，每只衍生物特殊召唤成功时为其注册离场伤害效果；最后完成特殊召唤处理。
function c42956963.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查：若对方主要怪兽区空格少于3个，则本次特殊召唤处理不适用。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<3 then return end
	-- 效果处理时再次检查：若自己已经不能特殊召唤该衍生物，则本次特殊召唤处理不适用。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,42956964,0x45,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) then return end
	for i=1,3 do
		-- 创建1只“梦魇恶魔衍生物”（卡号42956964），持有者为自己。
		local token=Duel.CreateToken(tp,42956964)
		-- 将衍生物以表侧攻击表示特殊召唤到对方场上，作为多重特殊召唤的一步；若成功则继续为它注册效果。
		if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK) then
			-- 「梦魇恶魔衍生物」被破坏时那控制者受到每1只800伤害。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(c42956963.damop)
			token:RegisterEffect(e1,true)
		end
	end
	-- 完成整个特殊召唤处理，触发特殊召唤成功的时点。
	Duel.SpecialSummonComplete()
end
-- 衍生物离场时的诱发效果：若该衍生物是被破坏离场，则给予其离场前的控制者800点效果伤害，处理完毕后重置该效果。
function c42956963.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 给予该衍生物离场前的控制者800点效果伤害。
		Duel.Damage(c:GetPreviousControler(),800,REASON_EFFECT)
	end
	e:Reset()
end
