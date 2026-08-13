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
	-- 设置效果值为aux.tgoval：当效果发动者不是本卡控制者时，视为不可成为对象，从而实现“不会成为对方的效果的对象”。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 「天空的虹彩」的②的效果1回合只能使用1次。②：以这张卡以外的自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1张「异色眼」卡加入手卡。
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
-- 定义①效果的保护对象：灵摆区域中属于「魔术师」（0x98）、「娱乐伙伴」（0x9f）、「异色眼」（0x99）字段的卡。
function c27813661.tgtg(e,c)
	return c:IsSetCard(0x98,0x9f,0x99)
end
-- 定义②效果可选对象的过滤条件：必须是表侧表示的卡。
function c27813661.desfilter(c)
	return c:IsFaceup()
end
-- 定义检索目标过滤条件：卡组中「异色眼」（0x99）字段且能够加入手卡的卡。
function c27813661.thfilter(c)
	return c:IsSetCard(0x99) and c:IsAbleToHand()
end
-- ②效果的发动条件与取对象处理：指定对象时验证其为场上表侧表示且非本卡；发动时检查存在可破坏的对象且卡组有可检索的「异色眼」卡。
function c27813661.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c27813661.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件检查（其一）：自己场上存在这张卡以外的表侧表示卡可以作为取对象的目标。
	if chk==0 then return Duel.IsExistingTarget(c27813661.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 发动条件检查（其二）：卡组中存在1张「异色眼」字段且可加入手卡的卡，与上一条件共同满足才能发动。
		and Duel.IsExistingMatchingCard(c27813661.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 弹出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张表侧表示且不是这张卡的卡作为效果对象，并设置为连锁对象。
	local g=Duel.SelectTarget(tp,c27813661.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 登记操作信息：本次效果包含破坏选中的1张卡，供连锁判定等相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记操作信息：本次效果包含从卡组将1张「异色眼」卡加入手卡，对象在处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时的实际操作：取得对象并破坏，若破坏成功则从卡组检索「异色眼」卡加入手卡并让对方确认。
function c27813661.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡仍与效果关联且成功被效果破坏；破坏成功后才执行后续检索。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 弹出选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选出1张满足条件的「异色眼」卡。
		local g=Duel.SelectMatchingCard(tp,c27813661.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选出的「异色眼」卡加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的那张卡，确认检索内容。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
