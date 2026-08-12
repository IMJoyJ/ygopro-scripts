--三位一択
-- 效果：
-- 宣言额外卡组的怪兽卡的种类（融合·同调·超量）才能发动。双方的额外卡组全部确认，宣言的种类的卡数量多的玩家回复3000基本分。
function c73988674.initial_effect(c)
	-- 宣言额外卡组的怪兽卡的种类（融合·同调·超量）才能发动。双方的额外卡组全部确认
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73988674.target)
	e1:SetOperation(c73988674.operation)
	c:RegisterEffect(e1)
end
-- 检查双方额外卡组是否都存在里侧表示的卡，作为发动的可行性判断
function c73988674.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方额外卡组是否存在至少1张里侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查对方额外卡组是否存在至少1张里侧表示的卡
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_EXTRA,1,nil) end
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让发动玩家选择宣言的种类（融合、同调或超量），并用Label记录选择结果
	local op=Duel.SelectOption(tp,aux.Stringid(73988674,0),aux.Stringid(73988674,1),aux.Stringid(73988674,2))  --"融合卡/同调卡/超量卡"
	e:SetLabel(op)
end
-- 获取双方额外卡组并互相确认，然后根据Label确定宣言的怪兽卡种类
function c73988674.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组的卡片组
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 将己方额外卡组的卡片给对方确认
	Duel.ConfirmCards(1-tp,g1)
	-- 获取对方额外卡组的卡片组
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 将对方额外卡组的卡片给己方确认
	Duel.ConfirmCards(tp,g2)
	local tpe=0
	if e:GetLabel()==0 then tpe=TYPE_FUSION
	elseif e:GetLabel()==1 then tpe=TYPE_SYNCHRO
	else tpe=TYPE_XYZ end
	local ct1=g1:FilterCount(Card.IsType,nil,tpe)
	local ct2=g2:FilterCount(Card.IsType,nil,tpe)
	if ct1>ct2 then
		-- 若己方额外卡组中宣言种类的卡数量较多，则己方回复3000基本分
		Duel.Recover(tp,3000,REASON_EFFECT)
	elseif ct1<ct2 then
		-- 若对方额外卡组中宣言种类的卡数量较多，则对方回复3000基本分
		Duel.Recover(1-tp,3000,REASON_EFFECT)
	end
	-- 洗切己方额外卡组
	Duel.ShuffleExtra(tp)
	-- 洗切对方额外卡组
	Duel.ShuffleExtra(1-tp)
end
