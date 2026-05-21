--サイバー・エスパー
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，可以确认对方抽到的卡。
function c91663373.initial_effect(c)
	-- 只要这张卡在自己场上表侧攻击表示存在，可以确认对方抽到的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91663373,0))  --"确认抽卡"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c91663373.cfcon)
	e1:SetOperation(c91663373.cfop)
	c:RegisterEffect(e1)
end
-- 检查自身是否处于攻击表示，且抽卡玩家为对方
function c91663373.cfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos() and ep==1-tp
end
-- 过滤出在手牌中且未公开的卡片
function c91663373.filter(c)
	return c:IsLocation(LOCATION_HAND) and not c:IsPublic()
end
-- 若自身仍在场上表侧攻击表示存在，则筛选出对方抽到的卡给自身玩家确认，并洗切对方手牌
function c91663373.cfop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsPosition(POS_FACEUP_ATTACK) then
		local cg=eg:Filter(c91663373.filter,nil)
		-- 给自身玩家确认对方抽到的卡片
		Duel.ConfirmCards(tp,cg)
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-tp)
	end
end
