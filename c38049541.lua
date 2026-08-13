--A・ジェネクス・ケミストリ
-- 效果：
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「次世代」怪兽为对象，宣言1个属性才能发动。那只自己的「次世代」怪兽变成宣言的属性。
function c38049541.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「次世代」怪兽为对象，宣言1个属性才能发动。那只自己的「次世代」怪兽变成宣言的属性。
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
-- 效果发动代价：检查这张卡是否可作为代价丢弃，然后将这张卡从手卡丢弃来支付发动代价。
function c38049541.coscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以“代价”和“丢弃”的理由从手卡送去墓地，即支付代价丢弃自身。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：满足表侧表示且拥有「次世代」字段的怪兽，用于选择自己场上的1只「次世代」怪兽。
function c38049541.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2)
end
-- 发动阶段的选择处理：选择自己场上1只表侧表示的「次世代」怪兽为对象，并宣言1个属性，将宣言的属性记录到效果临时标签中。
function c38049541.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动合法性检查：自己场上有表侧表示的「次世代」怪兽存在时，该效果才满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(c38049541.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择表侧表示的卡”，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的「次世代」怪兽作为效果对象，并设置为连锁对象。
	local g=Duel.SelectTarget(tp,c38049541.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 给玩家显示属性选择提示，提示内容为“请选择要宣言的属性”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性，可选范围是全部属性中除去对象怪兽当前属性以外的属性，并将宣言结果存入效果标签，供效果处理时使用。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- 效果处理：若对象怪兽仍与效果关联且在自己场上表侧表示，则给其赋予一个改变属性的效果，使该怪兽属性变为玩家宣言的属性。
function c38049541.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and c38049541.filter(tc) then
		-- 那只自己的「次世代」怪兽变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
