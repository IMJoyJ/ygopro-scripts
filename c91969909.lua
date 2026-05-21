--女神ウルドの裁断
-- 效果：
-- ①：自己场上的「女武神」怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：1回合1次，宣言1个卡名，以对方场上盖放的1张卡为对象才能发动。那张盖放的卡给双方确认，宣言的卡的场合，那张卡除外。不是的场合，选自己场上1张卡除外。
function c91969909.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「女武神」怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为自己场上字段名含有「女武神」（0x122）的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x122))
	e2:SetValue(c91969909.indesval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方卡的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：1回合1次，宣言1个卡名，以对方场上盖放的1张卡为对象才能发动。那张盖放的卡给双方确认，宣言的卡的场合，那张卡除外。不是的场合，选自己场上1张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetDescription(aux.Stringid(91969909,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c91969909.rmtg)
	e4:SetOperation(c91969909.rmop)
	c:RegisterEffect(e4)
end
-- 判定效果的控制者是否为对方玩家（用于不会被对方效果破坏的判定）
function c91969909.indesval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
-- 过滤对方场上里侧表示且可以除外的卡片
function c91969909.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果②的发动准备与对象选择（宣言卡名并选择对方场上1张里侧表示的卡为对象）
function c91969909.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c91969909.rmfilter(chkc) end
	-- 判定对方场上是否存在可以作为对象的里侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c91969909.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择里侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上1张里侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c91969909.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 给玩家发送宣言卡名的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家宣言一个卡名
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡名保存为当前连锁的对象参数
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为需要宣言卡名的效果
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果②的效果处理（确认盖放的卡，若与宣言卡名相同则除外，否则除外自己场上1张卡）
function c91969909.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时宣言的卡名参数
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if not (e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFacedown()) then return end
	-- 将作为对象的盖放卡给双方确认
	Duel.ConfirmCards(tp,tc)
	if tc:IsCode(ac) then
		-- 将该卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	else
		-- 给玩家发送选择除外卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择自己场上1张可以除外的卡片
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 then
			-- 将选中的自己场上的卡片表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
