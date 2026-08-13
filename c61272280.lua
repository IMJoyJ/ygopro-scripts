--絶火の竜神ヴァフラム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：同调召唤的这张卡被破坏的场合才能发动。对方场上的表侧表示的卡全部破坏。
-- ②：有这张卡装备的怪兽不会被对方的魔法·陷阱卡的效果破坏。
-- ③：有这张卡装备的怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
function c61272280.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整无额外限制（nil），调整以外怪兽仅需1只，对应召唤条件“调整＋调整以外的怪兽1只以上”。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：同调召唤的这张卡被破坏的场合才能发动。对方场上的表侧表示的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61272280,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,61272280)
	e1:SetCondition(c61272280.descon)
	e1:SetTarget(c61272280.destg)
	e1:SetOperation(c61272280.desop)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽不会被对方的魔法·陷阱卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(c61272280.indesval)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：有这张卡装备的怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61272280,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,61272281)
	e3:SetCondition(c61272280.descon2)
	e3:SetTarget(c61272280.destg2)
	e3:SetOperation(c61272280.desop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡在被破坏前位于怪兽区，并且是通过同调召唤出场（即“同调召唤的这张卡被破坏的场合”）。
function c61272280.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果发动时的目标处理：获取对方场上的所有表侧表示的卡（场上正面表示的卡），若存在则允许发动，并设置破坏这些卡的操作信息。
function c61272280.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取以发动者tp来看的对方场上（含怪兽区和魔陷区）所有表侧表示的卡的集合，作为可能被破坏的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁操作信息，标明本次效果将破坏集合g中的全部卡片，破坏分类为CATEGORY_DESTROY，数量为#g，用于让其他卡能连锁此效果的破坏动作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ①效果处理时：重新获取对方场上的表侧表示卡，若仍有卡存在，则将这些卡全部效果破坏。
function c61272280.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 与第7行相同，效果处理时重新获取对方场上表侧表示卡的集合，确保破坏的是处理时在场的卡。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		-- 以效果破坏（REASON_EFFECT）为原因将集合g中的所有卡破坏并送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的免疫判定：当装备怪兽受到来自对手的魔法/陷阱卡的效果影响时，返回真，使其不会被该效果破坏。
function c61272280.indesval(e,re,rp)
	-- 返回真当且仅当效果发动者是装备怪兽持有者的对手，并且该效果是魔法或陷阱卡的效果，即对方魔陷效果无法破坏装备怪兽。
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果的发动条件：这张卡作为装备卡存在时，其装备怪兽与对方怪兽进行战斗的伤害步骤开始时才能发动。获取装备怪兽及其战斗对象（对方怪兽），若战斗对象是对方怪兽且仍关联战斗，则满足条件并保存该对象。
function c61272280.descon2(e,tp,eg,ep,ev,re,r,rp)
	local etc=e:GetHandler():GetEquipTarget()
	if not etc then return false end
	local bc=etc:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- ③效果发动时的目标处理：取出保存的对方战斗对象作为效果对象，若存在则允许发动，并设置破坏该对象的信息。
function c61272280.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置连锁操作信息，标明本次效果将破坏目标怪兽bc，破坏分类为CATEGORY_DESTROY，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- ③效果处理时：取出保存的对方怪兽，若仍存在且仍与战斗关联，则将其效果破坏。
function c61272280.desop2(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() then
		-- 以效果破坏（REASON_EFFECT）为原因将该对方怪兽破坏并送入墓地。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
