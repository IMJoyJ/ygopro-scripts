--運命の分かれ道
-- 效果：
-- 双方玩家各自进行1次投掷硬币。出现表侧的场合回复2000基本分，出现里侧的场合基本分受到2000分伤害。
function c50470982.initial_effect(c)
	-- 双方玩家各自进行1次投掷硬币。出现表侧的场合回复2000基本分，出现里侧的场合基本分受到2000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c50470982.target)
	e1:SetOperation(c50470982.activate)
	c:RegisterEffect(e1)
end
-- 发动时的判定函数：在 chk==0 时直接返回 true，表示该效果没有发动限制，可在自由时点正常发动；随后登记硬币效果信息。
function c50470982.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次连锁登记为硬币类效果，目标涉及双方玩家，参数为1，用于后续时点和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,PLAYER_ALL,1)
end
-- 效果处理函数：让发动玩家和对方玩家各进行1次投掷硬币，再根据各自投掷结果分别进行回复或伤害处理。
function c50470982.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让发动玩家 tp 投掷1枚硬币，返回结果（1为表侧，0为里侧）。
	local res=Duel.TossCoin(tp,1)
	-- 若发动玩家投掷结果为表侧，则其回复2000基本分。
	if res==1 then Duel.Recover(tp,2000,REASON_EFFECT)
	-- 若发动玩家投掷结果为里侧，则其受到2000基本分的伤害。
	else Duel.Damage(tp,2000,REASON_EFFECT) end
	-- 让对方玩家（1-tp）也投掷1枚硬币，返回结果。
	res=Duel.TossCoin(1-tp,1)
	-- 若对方投掷结果为表侧，则对方回复2000基本分。
	if res==1 then Duel.Recover(1-tp,2000,REASON_EFFECT)
	-- 若对方投掷结果为里侧，则对方受到2000基本分的伤害。
	else Duel.Damage(1-tp,2000,REASON_EFFECT) end
end
