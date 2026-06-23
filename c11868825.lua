--ゴブリンの秘薬
-- 效果：
-- ①：自己回复600基本分。
function c11868825.initial_effect(c)
	-- ①：自己回复600基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11868825.rectg)
	e1:SetOperation(c11868825.recop)
	c:RegisterEffect(e1)
end
-- 效果处理时的目标设定函数
function c11868825.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前效果的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前效果的目标参数设置为600
	Duel.SetTargetParam(600)
	-- 设置效果操作信息为回复600基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
end
-- 效果处理时的执行函数
function c11868825.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应参数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
