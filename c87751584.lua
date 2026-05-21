--ガトリング・ドラゴン
-- 效果：
-- 「左轮手枪龙」＋「回膛手枪龙」
-- 投掷3个硬币。其中出现的与表侧硬币的数量同等数量的场上怪兽被破坏。这个效果1个回合1次，在自己的主要阶段使用。
function c87751584.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「左轮手枪龙」和「回膛手枪龙」
	aux.AddFusionProcCode2(c,81480460,25551951,true,true)
	-- 投掷3个硬币。其中出现的与表侧硬币的数量同等数量的场上怪兽被破坏。这个效果1个回合1次，在自己的主要阶段使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87751584,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c87751584.destg)
	e1:SetOperation(c87751584.desop)
	c:RegisterEffect(e1)
end
-- 效果的发动准备与条件检测函数（Target）
function c87751584.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，表明此效果包含投掷3次硬币的操作
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果的实际处理函数（Operation）
function c87751584.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的怪兽作为可选的破坏对象
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 让玩家投掷3次硬币，并获取每次投掷的结果（1为正面，0为反面）
	local c1,c2,c3=Duel.TossCoin(tp,3)
	local ct=c1+c2+c3
	if ct==0 then return end
	if ct>g:GetCount() then ct=g:GetCount() end
	-- 给玩家发送选择破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,ct,ct,nil)
	-- 显式展示被选择的卡片（在游戏画面中闪烁显示）
	Duel.HintSelection(dg)
	-- 将选中的怪兽因效果破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
