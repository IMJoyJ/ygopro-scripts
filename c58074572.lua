--モウヤンのカレー
-- 效果：
-- 回复200点基本分。
function c58074572.initial_effect(c)
	-- 回复200点基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58074572.rectg)
	e1:SetOperation(c58074572.recop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与信息设置
function c58074572.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让发动玩家选择是回复自己还是回复对方的基本分
	local opt=Duel.SelectOption(tp,aux.Stringid(58074572,0),aux.Stringid(58074572,1))  --"回复己方200点基本分/回复对方200点基本分"
	local p=(opt==0 and tp or 1-tp)
	-- 设置当前连锁的对象玩家为所选玩家
	Duel.SetTargetPlayer(p)
	-- 设置当前连锁的对象参数为回复数值200
	Duel.SetTargetParam(200)
	-- 设置当前连锁的操作信息为回复200点基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,p,200)
end
-- 效果处理的执行
function c58074572.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
