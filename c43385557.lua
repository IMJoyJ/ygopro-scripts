--マジカル・アンドロイド
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己的结束阶段时，回复自己场上表侧表示存在的念动力族怪兽数量×600的数值的基本分。
function c43385557.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
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
-- 效果发动的条件判断函数，判断是否为当前回合玩家
function c43385557.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤场上表侧表示存在的念动力族怪兽
function c43385557.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 设置效果的目标玩家和回复LP数量，并注册效果操作信息
function c43385557.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计场上表侧表示存在的念动力族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c43385557.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置效果影响的玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果回复的LP数值为念动力族怪兽数量乘以600
	Duel.SetTargetParam(ct*600)
	-- 注册效果操作信息，指定效果类别为回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*600)
end
-- 效果的处理函数，根据场上念动力族怪兽数量回复相应LP
function c43385557.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次统计场上表侧表示存在的念动力族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c43385557.filter,tp,LOCATION_MZONE,0,nil)
	-- 使当前玩家回复指定数量的LP，原因来自效果
	Duel.Recover(tp,ct*600,REASON_EFFECT)
end
