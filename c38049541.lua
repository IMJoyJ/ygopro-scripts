--A・ジェネクス・ケミストリ
-- 效果：
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「次世代」怪兽为对象，宣言1个属性才能发动。那只自己的「次世代」怪兽变成宣言的属性。
function c38049541.initial_effect(c)
	-- 效果原文：①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「次世代」怪兽为对象，宣言1个属性才能发动。那只自己的「次世代」怪兽变成宣言的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38049541,0))  --"属性变化"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c38049541.coscost)
	e1:SetTarget(c38049541.costg)
	e1:SetOperation(c38049541.cosop)
	c:RegisterEffect(e1)
end
-- 效果作用：支付代价，将自身从手牌丢弃
function c38049541.coscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 效果作用：将自身送入墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义可用于选择的目标怪兽过滤器，必须为表侧表示且为「次世代」族
function c38049541.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2)
end
-- 效果作用：选择对象怪兽并宣言属性
function c38049541.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 效果作用：判断是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c38049541.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择符合条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c38049541.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：提示玩家宣言一个属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 效果作用：让玩家宣言一个属性，不能宣言已存在的属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- 效果作用：将选定怪兽的属性更改为宣言的属性
function c38049541.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and c38049541.filter(tc) then
		-- 效果原文：那只自己的「次世代」怪兽变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
