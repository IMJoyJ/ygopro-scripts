--天空の虹彩
-- 效果：
-- 「天空的虹彩」的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，自己的灵摆区域的「魔术师」卡、「娱乐伙伴」卡、「异色眼」卡不会成为对方的效果的对象。
-- ②：以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1张「异色眼」卡加入手卡。
function c27813661.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己的灵摆区域的「魔术师」卡、「娱乐伙伴」卡、「异色眼」卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_PZONE,0)
	e2:SetTarget(c27813661.tgtg)
	-- 设置效果值为aux.tgoval函数，用于判断目标是否不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1张「异色眼」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27813661,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,27813661)
	e3:SetTarget(c27813661.destg)
	e3:SetOperation(c27813661.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断目标卡是否为「魔术师」、「娱乐伙伴」或「异色眼」卡
function c27813661.tgtg(e,c)
	return c:IsSetCard(0x98,0x9f,0x99)
end
-- 过滤函数，判断目标卡是否为表侧表示
function c27813661.desfilter(c)
	return c:IsFaceup()
end
-- 过滤函数，判断目标卡是否为「异色眼」卡且可以加入手牌
function c27813661.thfilter(c)
	return c:IsSetCard(0x99) and c:IsAbleToHand()
end
-- 设置效果的发动条件，检查是否满足选择破坏对象和检索「异色眼」卡的条件
function c27813661.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c27813661.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在至少1张表侧表示的卡作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(c27813661.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查自己卡组中是否存在至少1张「异色眼」卡
		and Duel.IsExistingMatchingCard(c27813661.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张自己控制的表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c27813661.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，记录将要加入手牌的「异色眼」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行破坏和检索操作
function c27813661.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上且与当前效果相关，然后进行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 向玩家提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「异色眼」卡加入手牌
		local g=Duel.SelectMatchingCard(tp,c27813661.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「异色眼」卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
