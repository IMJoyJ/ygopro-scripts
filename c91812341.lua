--トリオンの蟲惑魔
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1张「洞」通常陷阱卡或者「落穴」通常陷阱卡加入手卡。
-- ②：这张卡特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象发动。那张对方的卡破坏。
-- ③：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
function c91812341.initial_effect(c)
	-- ③：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c91812341.efilter)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「洞」通常陷阱卡或者「落穴」通常陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91812341,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c91812341.thtg)
	e2:SetOperation(c91812341.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象发动。那张对方的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91812341,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c91812341.destg)
	e3:SetOperation(c91812341.desop)
	c:RegisterEffect(e3)
end
-- 免疫效果过滤：判断是否为「洞」通常陷阱卡或「落穴」通常陷阱卡
function c91812341.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 检索卡片过滤：判断是否为可加入手牌的「洞」通常陷阱卡或「落穴」通常陷阱卡
function c91812341.filter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组是否存在满足条件的卡，并设置检索的操作信息
function c91812341.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己卡组是否存在至少1张满足条件的「洞」或「落穴」通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91812341.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从自己卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张「洞」或「落穴」通常陷阱卡加入手牌并给对方确认
function c91812341.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「洞」或「落穴」通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c91812341.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏对象过滤：判断是否为魔法·陷阱卡
function c91812341.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的发动准备：选择对方场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function c91812341.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c91812341.desfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c91812341.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果的处理：破坏作为对象的卡片
function c91812341.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
