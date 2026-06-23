--ベルキャットファイター
-- 效果：
-- 包含衍生物的怪兽3只
-- ①：这张卡战斗破坏对方怪兽时才能发动。在自己场上把1只「铃猫衍生物」（机械族·风·4星·攻/守2000）守备表示特殊召唤。
function c22953211.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用3个连接素材，且素材中必须包含衍生物
	aux.AddLinkProcedure(c,nil,3,3,c22953211.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽时才能发动。在自己场上把1只「铃猫衍生物」（机械族·风·4星·攻/守2000）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22953211,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为：此卡与对方怪兽战斗且战斗破坏对方怪兽
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c22953211.tktg)
	e1:SetOperation(c22953211.tkop)
	c:RegisterEffect(e1)
end
-- 连接素材检查函数，确保连接素材中至少包含1只衍生物
function c22953211.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TOKEN)
end
-- 设置效果的发动时点为战斗破坏对方怪兽时，检查是否满足特殊召唤衍生物的条件
function c22953211.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22953212,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_MACHINE,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息，表示将特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息，表示将特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 设置效果的发动时点为战斗破坏对方怪兽时，检查是否满足特殊召唤衍生物的条件
function c22953211.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,22953212,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_MACHINE,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	-- 创建1只指定编号的衍生物
	local token=Duel.CreateToken(tp,22953212)
	-- 将创建的衍生物以守备表示特殊召唤到玩家场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
