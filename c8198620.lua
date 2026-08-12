--冥界龍 ドラゴネクロ
-- 效果：
-- 不死族怪兽×2
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：「冥界龙 龙亡」在自己场上只能有1只表侧表示存在。
-- ②：和这张卡进行战斗的怪兽不会被那次战斗破坏。
-- ③：这张卡和怪兽进行战斗的伤害步骤结束时发动。那只怪兽的攻击力变成0，把持有和那只怪兽的原本的等级·攻击力相同等级·攻击力的1只「暗魂体衍生物」（不死族·暗·攻?/守0）在自己场上特殊召唤。
function c8198620.initial_effect(c)
	c:SetUniqueOnField(1,0,8198620)
	c:EnableReviveLimit()
	-- 设置融合素材为2只不死族怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),2,true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	-- 限制该卡只能通过融合召唤的方式从额外卡组特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ③：这张卡和怪兽进行战斗的伤害步骤结束时发动。那只怪兽的攻击力变成0，把持有和那只怪兽的原本的等级·攻击力相同等级·攻击力的1只「暗魂体衍生物」（不死族·暗·攻?/守0）在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8198620,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置效果的发动条件为伤害步骤结束时，且自身仍在场或因战斗被破坏
	e2:SetCondition(aux.dsercon)
	e2:SetTarget(c8198620.attg)
	e2:SetOperation(c8198620.atop)
	c:RegisterEffect(e2)
	-- ②：和这张卡进行战斗的怪兽不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c8198620.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果③的发动检测与靶向函数：检查战斗对象是否存在且仍处于战斗关联状态，并宣告将要产生衍生物和特殊召唤的操作信息
function c8198620.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	-- 宣告连锁处理中包含产生衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 宣告连锁处理中包含特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果③的执行函数：将战斗怪兽的攻击力变为0，并在自己场上特殊召唤一只复制其原本等级和攻击力的「暗魂体衍生物」
function c8198620.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		local lv=bc:GetOriginalLevel()
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		-- 检查战斗怪兽的原本等级是否大于0，且自己场上是否有可用的怪兽区域
		if lv>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查玩家是否能够特殊召唤指定的「暗魂体衍生物」（不死族·暗·攻?/守0）
			and Duel.IsPlayerCanSpecialSummonMonster(tp,8198621,0,TYPES_TOKEN_MONSTER,-2,0,0,RACE_ZOMBIE,ATTRIBUTE_DARK) then
			-- 在后台创建「暗魂体衍生物」的卡片数据
			local token=Duel.CreateToken(tp,8198621)
			local atk=bc:GetBaseAttack()
			-- 把持有和那只怪兽的原本的等级·攻击力相同等级·攻击力的1只「暗魂体衍生物」（不死族·暗·攻?/守0）在自己场上特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(lv)
			token:RegisterEffect(e2)
			-- 将创建并设定好属性的衍生物以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤出与这张卡进行战斗的怪兽，作为不会被战斗破坏的效果对象
function c8198620.indestg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
