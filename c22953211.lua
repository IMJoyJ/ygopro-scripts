--ベルキャットファイター
-- 效果：
-- 包含衍生物的怪兽3只
-- ①：这张卡战斗破坏对方怪兽时才能发动。在自己场上把1只「铃猫衍生物」（机械族·风·4星·攻/守2000）守备表示特殊召唤。
function c22953211.initial_effect(c)
	-- 为「铃猫战斗机」添加连接召唤手续：需要用3只怪兽作为连接素材，并且素材组必须通过c22953211.lcheck的追加检查（即包含衍生物）。
	aux.AddLinkProcedure(c,nil,3,3,c22953211.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽时才能发动。在自己场上把1只「铃猫衍生物」（机械族·风·4星·攻/守2000）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22953211,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件为aux.bdocon，即此卡与对方怪兽进行战斗并将其破坏的场合才满足发动条件。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c22953211.tktg)
	e1:SetOperation(c22953211.tkop)
	c:RegisterEffect(e1)
end
-- 连接素材的追加过滤函数：检查选中的连接素材组g中是否至少存在1只衍生物，以满足「包含衍生物的怪兽3只」的召唤条件。
function c22953211.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TOKEN)
end
-- 效果的发动时点目标处理函数（tktg）：主要确认是否满足发动所需的场地条件和特殊召唤条件。
function c22953211.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查（chk==0）时，先确认自己主要怪兽区域仍有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己能够将「铃猫衍生物」（机械族·风·4星·攻/守2000）以表侧守备表示特殊召唤到自己的主要怪兽区。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22953212,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_MACHINE,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次效果将生成1只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果将进行1次特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理函数（tkop）：实际执行特殊召唤衍生物的操作，处理前再次检查场地空位与特殊召唤是否仍被允许。
function c22953211.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区域没有空位，则本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若当前无法特殊召唤「铃猫衍生物」，则本次效果不处理（与无空位任一条件不满足即返回）。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,22953212,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_MACHINE,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	-- 创建1只卡编号为22953212的「铃猫衍生物」token，控制者为tp。
	local token=Duel.CreateToken(tp,22953212)
	-- 将刚创建的「铃猫衍生物」以表侧守备表示特殊召唤到tp的场上（不检查召唤条件与苏生限制）。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
