--ナイトメア・デーモンズ
-- 效果：
-- ①：把自己场上1只怪兽解放才能发动。在对方场上把3只「梦魇恶魔衍生物」（恶魔族·暗·6星·攻/守2000）攻击表示特殊召唤。「梦魇恶魔衍生物」被破坏时那控制者受到每1只800伤害。
function c42956963.initial_effect(c)
	-- 效果原文内容：①：把自己场上1只怪兽解放才能发动。在对方场上把3只「梦魇恶魔衍生物」（恶魔族·暗·6星·攻/守2000）攻击表示特殊召唤。「梦魇恶魔衍生物」被破坏时那控制者受到每1只800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c42956963.cost)
	e1:SetTarget(c42956963.target)
	e1:SetOperation(c42956963.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足解放1只怪兽的费用条件
function c42956963.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择1张满足条件的可解放卡
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 以REASON_COST原因解放所选卡
	Duel.Release(g,REASON_COST)
end
-- 检测是否满足特殊召唤衍生物的条件
function c42956963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查对方场上是否有至少3个空区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>2
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,42956964,0x45,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) end
	-- 设置连锁操作信息为召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置连锁操作信息为特殊召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 发动效果时执行的操作
function c42956963.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查对方场上是否至少有3个空区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<3 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,42956964,0x45,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,1-tp) then return end
	for i=1,3 do
		-- 创建一只指定编号的衍生物
		local token=Duel.CreateToken(tp,42956964)
		-- 尝试特殊召唤该衍生物
		if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK) then
			-- 为衍生物注册一个离开场上的效果，用于触发伤害
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(c42956963.damop)
			token:RegisterEffect(e1,true)
		end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 衍生物被破坏时触发的伤害处理函数
function c42956963.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 对衍生物的控制者造成800点伤害
		Duel.Damage(c:GetPreviousControler(),800,REASON_EFFECT)
	end
	e:Reset()
end
