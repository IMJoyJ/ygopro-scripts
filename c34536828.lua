--烙印の使徒
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方发动的怪兽的效果处理时，自己场上有8星以上的恶魔族融合怪兽存在，那只对方怪兽的攻击力或者守备力是0的场合，可以把那个发动的效果无效。
-- ②：攻击力0的怪兽之间进行战斗的伤害步骤结束时才能发动。那只进行战斗的对方怪兽破坏。
function c34536828.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方发动的怪兽的效果处理时，自己场上有8星以上的恶魔族融合怪兽存在，那只对方怪兽的攻击力或者守备力是0的场合，可以把那个发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c34536828.disop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：攻击力0的怪兽之间进行战斗的伤害步骤结束时才能发动。那只进行战斗的对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,34536828)
	e3:SetCondition(c34536828.descon)
	e3:SetOperation(c34536828.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定卡片是否为表侧表示、8星以上、恶魔族、融合怪兽，用于检查自己场上是否存在满足①效果发动条件的融合怪兽。
function c34536828.disfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsLevelAbove(8) and c:IsFaceup()
end
-- ①效果的处理操作：在连锁处理时，若满足对方发动的是可被无效的怪兽效果、对方该怪兽攻击力或守备力为0、自己场上有8星以上恶魔族融合怪兽、本回合未使用过①效果，并询问玩家确认发动后，将该效果无效并给本卡设置本回合已使用的标志。
function c34536828.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判断是否为对方发动的怪兽效果、当前连锁效果能够被无效、本回合本卡尚未使用过①效果。
	if rp==1-tp and Duel.IsChainDisablable(ev) and c:GetFlagEffect(34536828)==0 and re:IsActiveType(TYPE_MONSTER)
		and (rc:IsFaceup() and rc:IsLocation(LOCATION_MZONE) and (rc:IsAttack(0) or rc:IsDefense(0))
			or not (rc:IsFaceup() and rc:IsLocation(LOCATION_MZONE)) and (rc:GetTextAttack()==0 or not rc:IsType(TYPE_LINK) and rc:GetTextDefense()==0))
		-- 检查自己场上是否存在至少1张满足 disfilter 条件的表侧表示8星以上恶魔族融合怪兽。
		and Duel.IsExistingMatchingCard(c34536828.disfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 弹出“是否适用「烙印的使徒」的效果来无效？”的选择询问，由玩家决定是否发动①效果。
		and Duel.SelectEffectYesNo(tp,c,aux.Stringid(34536828,0)) then  --"是否适用「烙印的使徒」的效果来无效？"
		-- 向双方展示卡片「烙印的使徒」的发动/适用动画，作为无效效果时的提示。
		Duel.Hint(HINT_CARD,0,34536828)
		-- 将当前连锁编号 ev 对应的对方怪兽效果无效化。
		Duel.NegateEffect(ev)
		c:RegisterFlagEffect(34536828,RESET_PHASE+PHASE_END,0,0)
	end
end
-- ②效果的发动条件：在伤害步骤结束时，己方和对方的战斗怪兽都存在且攻击力都为0，并且对方怪兽仍与这次战斗有关联。
function c34536828.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方正在战斗的怪兽 a 和对方正在战斗的怪兽 d（若没有战斗或没有对应怪兽则为 nil）。
	local a,d=Duel.GetBattleMonster(tp)
	return a and d and a:IsAttack(0) and d:IsAttack(0) and d:IsRelateToBattle()
end
-- ②效果的处理：若对方那只进行战斗的怪兽仍与这次战斗相关，则将其破坏。
function c34536828.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方正在战斗的怪兽 a 和对方正在战斗的怪兽 d（若没有战斗或没有对应怪兽则为 nil）。
	local a,d=Duel.GetBattleMonster(tp)
	if d and d:IsRelateToBattle() then
		-- 以效果为原因破坏对方那只进行战斗的怪兽。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
