--久遠の魔術師ミラ
-- 效果：
-- ①：这张卡召唤成功的场合，以对方场上1张里侧表示的卡为对象发动。把那张对方的卡确认。对方不能对应这个效果的发动把魔法·陷阱卡发动。
function c33225925.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以对方场上1张里侧表示的卡为对象发动。把那张对方的卡确认。对方不能对应这个效果的发动把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33225925,0))  --"确认对方场上盖放的1张卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33225925.target)
	e1:SetOperation(c33225925.operation)
	c:RegisterEffect(e1)
end
-- 选择对方场上里侧表示的卡作为对象
function c33225925.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向玩家提示“请选择一张要确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(33225925,1))  --"请选择一张要确认的卡"
	-- 选择对方场上1张里侧表示的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁限制，禁止对方在效果发动时连锁发动魔法·陷阱卡
	Duel.SetChainLimit(c33225925.chainlimit)
end
-- 连锁限制函数，阻止对方连锁发动魔法·陷阱卡
function c33225925.chainlimit(e,rp,tp)
	return tp==rp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 确认选择的对方场上的里侧表示的卡
function c33225925.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 向玩家确认目标卡的卡面信息
		Duel.ConfirmCards(tp,tc)
	end
end
