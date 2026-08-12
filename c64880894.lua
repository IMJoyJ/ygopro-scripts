--スターダスト・チャージ・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤时才能发动。自己抽1张。
-- ②：这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
function c64880894.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡同调召唤时才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64880894,0))  --"抽1张卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,64880894)
	e1:SetCondition(c64880894.drcon)
	e1:SetTarget(c64880894.drtg)
	e1:SetOperation(c64880894.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(c64880894.atkfilter)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为同调召唤成功，作为效果发动的条件
function c64880894.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 抽卡效果的发动目标与操作信息设置
function c64880894.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家当前是否能够执行抽1张卡的操作
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的效果处理对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果处理参数（抽卡张数）设置为1
	Duel.SetTargetParam(1)
	-- 向系统宣告当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理函数
function c64880894.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果：让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤出可以被此卡攻击的怪兽：必须是特殊召唤的怪兽
function c64880894.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
