--暴れ牛鬼
-- 效果：
-- 猜硬币正反。
-- ●猜中的场合：给与对方基本分1000分的伤害。
-- ●猜错的场合：自己基本分受到1000分的伤害。这个效果1回合只能1次，在自己回合的主要阶段使用。
function c89718302.initial_effect(c)
	-- 猜硬币正反。●猜中的场合：给与对方基本分1000分的伤害。●猜错的场合：自己基本分受到1000分的伤害。这个效果1回合只能1次，在自己回合的主要阶段使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89718302,0))  --"猜硬币"
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c89718302.damtg)
	e1:SetOperation(c89718302.damop)
	c:RegisterEffect(e1)
end
-- 效果的发动准备函数，确认是否满足发动条件并设置操作信息
function c89718302.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理的执行函数，处理猜硬币及后续的伤害结算
function c89718302.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择硬币的正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让发动效果的玩家宣言硬币的正反面并记录
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币的操作并记录结果
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 猜中的场合，给与对方玩家1000点伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	else
		-- 猜错的场合，自己受到1000点伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
