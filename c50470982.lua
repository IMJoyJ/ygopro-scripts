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
-- 设置连锁操作信息，表明此效果为硬币投掷相关效果
function c50470982.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为CATEGORY_COIN，影响双方玩家，投掷1次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,PLAYER_ALL,1)
end
-- 执行硬币投掷并根据结果回复或造成伤害
function c50470982.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家投掷1次硬币，返回结果0或1
	local res=Duel.TossCoin(tp,1)
	-- 若硬币为正面（1），则当前玩家回复2000基本分
	if res==1 then Duel.Recover(tp,2000,REASON_EFFECT)
	-- 若硬币为反面（0），则当前玩家受到2000基本分伤害
	else Duel.Damage(tp,2000,REASON_EFFECT) end
	-- 让对方玩家投掷1次硬币，返回结果0或1
	res=Duel.TossCoin(1-tp,1)
	-- 若硬币为正面（1），则对方玩家回复2000基本分
	if res==1 then Duel.Recover(1-tp,2000,REASON_EFFECT)
	-- 若硬币为反面（0），则对方玩家受到2000基本分伤害
	else Duel.Damage(1-tp,2000,REASON_EFFECT) end
end
