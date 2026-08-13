--エンシェント・リーフ
-- 效果：
-- ①：自己基本分是9000以上的场合，支付2000基本分才能发动。自己从卡组抽2张。
function c11830996.initial_effect(c)
	-- ①：自己基本分是9000以上的场合，支付2000基本分才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c11830996.condition)
	e1:SetCost(c11830996.cost)
	e1:SetTarget(c11830996.target)
	e1:SetOperation(c11830996.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：当前发动玩家基本分在9000以上时才可发动。
function c11830996.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动玩家当前基本分，判断是否大于等于9000。
	return Duel.GetLP(tp)>=9000
end
-- 定义效果的发动代价：支付2000基本分。
function c11830996.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让发动玩家支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- 定义效果发动时的合法性检查与对象设定：确认发动玩家可以抽2张，并将后续处理所需的玩家与张数信息写入连锁。
function c11830996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，判定发动玩家是否能够抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，表示抽卡张数为2。
	Duel.SetTargetParam(2)
	-- 设置操作信息：本次效果包含抽卡分类，对象玩家为发动玩家，抽卡数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义效果处理时执行的动作：根据连锁记录中的玩家和数量进行抽卡。
function c11830996.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽取对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
