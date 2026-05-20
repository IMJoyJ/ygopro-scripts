--アルカナフォースⅠ－THE MAGICIAN
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：魔法卡发动时，直到那个回合的结束阶段时这张卡的原本攻击力变成2倍。
-- ●里：每次魔法卡发动对方回复500基本分。
function c8396952.initial_effect(c)
	-- 注册该卡在召唤、反转召唤、特殊召唤成功时强制发动投掷硬币的效果，并根据结果添加对应的标记。
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：魔法卡发动时，直到那个回合的结束阶段时这张卡的原本攻击力变成2倍。●里：每次魔法卡发动对方回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果触发条件为该怪兽已完成召唤成功时的投掷硬币判定（存在硬币标记）。
	e1:SetCondition(aux.ArcanaCondition)
	e1:SetOperation(c8396952.speop)
	c:RegisterEffect(e1)
end
-- 在连锁处理结束时，判断是否有魔法卡发动，并根据硬币投掷结果（表或里）分别执行对应的效果分支。
function c8396952.speop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsActiveType(TYPE_SPELL) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local val=c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)
	if val==1 then
		-- ●表：魔法卡发动时，直到那个回合的结束阶段时这张卡的原本攻击力变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	else
		-- 以效果原因使对方玩家回复500点基本分。
		Duel.Recover(1-tp,500,REASON_EFFECT)
	end
end
