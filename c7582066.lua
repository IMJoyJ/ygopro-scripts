--サイコ・デビル
-- 效果：
-- 调整＋调整以外的念动力族怪兽1只以上
-- ①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张，对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜中的场合，这张卡的攻击力直到下次的对方回合的结束时上升1000。
function c7582066.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的念动力族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_PSYCHO),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。对方手卡随机选1张，对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜中的场合，这张卡的攻击力直到下次的对方回合的结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7582066,0))  --"猜手卡"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c7582066.atkcon)
	e1:SetOperation(c7582066.atkop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：对方手牌数量不为0
function c7582066.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方手牌数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
end
-- 定义效果处理：随机选择对方1张手牌，让自身玩家猜测其种类，确认该卡，若猜中则提升这张卡的攻击力
function c7582066.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡已离场、变为里侧表示，或对方手牌为0，则不处理效果
	if not c:IsRelateToEffect(e) or c:IsFacedown() or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	-- 从对方手牌中随机选择1张卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	local tc=g:GetFirst()
	-- 提示玩家选择一个卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱）
	local op=Duel.AnnounceType(tp)
	-- 给自身玩家确认选中的那张对方手牌
	Duel.ConfirmCards(tp,tc)
	-- 洗切对方的手牌
	Duel.ShuffleHand(1-tp)
	if (op==0 and tc:IsType(TYPE_MONSTER)) or (op==1 and tc:IsType(TYPE_SPELL)) or (op==2 and tc:IsType(TYPE_TRAP)) then
		-- 这张卡的攻击力直到下次的对方回合的结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
