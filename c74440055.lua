--サボウ・ファイター
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，在对方场上把1只「针衍生物」（植物族·地·1星·攻/守500）守备表示特殊召唤。
function c74440055.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，在对方场上把1只「针衍生物」（植物族·地·1星·攻/守500）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74440055,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c74440055.condition)
	e1:SetTarget(c74440055.target)
	e1:SetOperation(c74440055.operation)
	c:RegisterEffect(e1)
end
-- 验证发动条件：自身仍与战斗关联，且战斗破坏的卡是怪兽
function c74440055.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 效果发动时的目标处理：因为是强制诱发效果，直接返回true，并设置特殊召唤和衍生物的操作信息
function c74440055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置当前连锁的操作信息为产生1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 效果处理：在对方场上特殊召唤1只「针衍生物」
function c74440055.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽区域是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查玩家是否能以表侧守备表示在对方场上特殊召唤指定的「针衍生物」（植物族·地·1星·攻/守500）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,74440056,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then
		-- 创建「针衍生物」卡片实例
		local token=Duel.CreateToken(tp,74440056)
		-- 将衍生物以表侧守备表示特殊召唤到对方场上
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
