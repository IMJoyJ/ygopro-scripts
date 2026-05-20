--M・HERO 闇鬼
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ②：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1张「变化」速攻魔法卡加入手卡。
function c59642500.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为必须通过「假面变化」的效果进行特殊召唤
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- 那次直接攻击给与对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(c59642500.rdcon)
	-- 设置给与对方的战斗伤害变成一半
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1张「变化」速攻魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCountLimit(1,59642500)
	e4:SetCondition(c59642500.thcon)
	e4:SetTarget(c59642500.thtg)
	e4:SetOperation(c59642500.thop)
	c:RegisterEffect(e4)
end
-- 伤害减半效果的条件判定函数（直接攻击且对方场上有怪兽存在时）
function c59642500.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判定攻击对象为空（即进行直接攻击）
	return Duel.GetAttackTarget()==nil
		-- 且自身没有获得复数次直接攻击效果，且对方场上存在怪兽
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 检索效果的发动条件判定（此卡在战斗中存活，且被破坏的战斗对象是怪兽并送去墓地）
function c59642500.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 过滤卡组中属于「变化」字段的速攻魔法卡
function c59642500.filter(c)
	return c:IsSetCard(0xa5) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- 检索效果的发动准备与目标检测函数
function c59642500.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在至少1张满足条件的「变化」速攻魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c59642500.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果的处理为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体执行函数
function c59642500.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「变化」速攻魔法卡
	local g=Duel.SelectMatchingCard(tp,c59642500.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
