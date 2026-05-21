--TG ハイパー・ライブラリアン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡在怪兽区域存在的状态，自己或对方把同调怪兽同调召唤的场合发动。这张卡在场上表侧表示存在的场合，自己抽1张。
function c90953320.initial_effect(c)
	-- 为卡片添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡在怪兽区域存在的状态，自己或对方把同调怪兽同调召唤的场合发动。这张卡在场上表侧表示存在的场合，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90953320,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c90953320.drcon)
	e1:SetTarget(c90953320.drtg)
	e1:SetOperation(c90953320.drop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：特殊召唤的怪兽数量为1、该怪兽不是此卡自身，且该召唤方式为同调召唤
function c90953320.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:GetFirst()
	return eg:GetCount()==1 and tg~=e:GetHandler() and tg:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果发动的目标：确定抽卡玩家为自己，抽卡数量为1张，并注册抽卡操作信息
function c90953320.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己（发动效果的玩家）
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果处理：确认此卡在场上表侧表示存在后，获取目标玩家和参数并执行抽卡
function c90953320.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取当前连锁中设定的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
