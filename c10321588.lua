--サンライト・ユニコーン
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。把自己卡组最上面的卡翻开，那是装备魔法卡的场合加入手卡。不是的场合，回到自己卡组最下面。
function c10321588.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段时才能发动。把自己卡组最上面的卡翻开，那是装备魔法卡的场合加入手卡。不是的场合，回到自己卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10321588,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c10321588.target)
	e1:SetOperation(c10321588.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置效果目标函数
function c10321588.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件（卡组不为空）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 效果作用：设置效果发动函数
function c10321588.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断卡组是否为空，为空则返回
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 效果作用：确认玩家卡组最上方1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 效果作用：获取玩家卡组最上方1张卡组成的组
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_EQUIP) and tc:IsAbleToHand() then
		-- 效果作用：禁用接下来的操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 效果作用：将目标卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：洗切玩家手牌
		Duel.ShuffleHand(tp)
	else
		-- 效果作用：将目标卡移至卡组最下方
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
