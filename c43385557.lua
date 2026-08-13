--マジカル・アンドロイド
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己的结束阶段时，回复自己场上表侧表示存在的念动力族怪兽数量×600的数值的基本分。
function c43385557.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整1只（不限条件）＋调整以外的怪兽1只以上，同时为后续的苏生限制做准备。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 自己的结束阶段时，回复自己场上表侧表示存在的念动力族怪兽数量×600的数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43385557,0))  --"回复LP"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c43385557.reccon)
	e1:SetTarget(c43385557.rectg)
	e1:SetOperation(c43385557.recop)
	c:RegisterEffect(e1)
end
-- 定义该触发效果的发动条件函数，用于判断是否满足“自己的结束阶段”这一时点。
function c43385557.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果控制者（tp），是则条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数：筛选自己场上表侧表示且种族为念动力族的怪兽。
function c43385557.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 定义效果发动时的目标处理函数：登记回复对象玩家、回复数值，并设置回复效果的操作信息。
function c43385557.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算自己场上表侧表示存在的念动力族怪兽数量，作为回复数值的计算基础。
	local ct=Duel.GetMatchingGroupCount(c43385557.filter,tp,LOCATION_MZONE,0,nil)
	-- 将当前连锁的对象玩家设置为自己（tp），表示回复对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为“念动力族怪兽数量×600”，即要回复的基本分数值。
	Duel.SetTargetParam(ct*600)
	-- 设置操作信息：本次连锁处理的是回复效果，预计回复tp玩家ct×600点基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*600)
end
-- 定义效果处理函数：在效果结算时重新计算场上表侧表示念动力族怪兽数量，并按数量×600回复基本分。
function c43385557.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取自己场上表侧表示存在的念动力族怪兽数量（因为发动后数量可能变化）。
	local ct=Duel.GetMatchingGroupCount(c43385557.filter,tp,LOCATION_MZONE,0,nil)
	-- 让控制者tp回复数值为（当前念动力族怪兽数量）×600的基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(tp,ct*600,REASON_EFFECT)
end
