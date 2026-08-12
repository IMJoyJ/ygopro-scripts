--ジュラック・イグアノン
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，可以让对方场上盖放的1张卡回到手卡。
function c71106375.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，可以让对方场上盖放的1张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71106375,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c71106375.thcon)
	e1:SetTarget(c71106375.thtg)
	e1:SetOperation(c71106375.thop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否因战斗破坏了怪兽以满足发动条件
function c71106375.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤场上里侧表示且能回到手牌的卡片
function c71106375.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 效果发动的对象选择与操作信息设置
function c71106375.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c71106375.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的里侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c71106375.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张里侧表示的卡片作为效果对象
	local g=Duel.SelectTarget(tp,c71106375.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置将该卡送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选中的对象卡片送回手牌
function c71106375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 通过效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
