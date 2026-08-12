--電動刃虫
-- 效果：
-- 这张卡进行战斗的场合，伤害步骤结束时对方玩家抽1张卡。
function c77252217.initial_effect(c)
	-- 这张卡进行战斗的场合，伤害步骤结束时对方玩家抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77252217,0))  --"对方抽1张卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置效果发动条件为该卡参与了战斗且处于伤害步骤结束时（使用辅助函数aux.dsercon）
	e1:SetCondition(aux.dsercon)
	e1:SetTarget(c77252217.drtg)
	e1:SetOperation(c77252217.drop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标处理：设置对方玩家为目标玩家，抽卡数量为1张，并向系统宣告抽卡操作信息
function c77252217.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为1（即抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：对方玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果运行处理：获取之前设定的目标玩家和参数，执行抽卡效果
function c77252217.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
