--青き眼の賢士
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。从卡组把「青色眼睛的贤士」以外的1只光属性·1星调整加入手卡。
-- ②：把这张卡从手卡丢弃，以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从卡组把1只「青眼」怪兽特殊召唤。
function c8240199.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把「青色眼睛的贤士」以外的1只光属性·1星调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c8240199.thtg)
	e1:SetOperation(c8240199.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡从手卡丢弃，以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从卡组把1只「青眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,8240199)
	e2:SetCost(c8240199.gvcost)
	e2:SetTarget(c8240199.gvtg)
	e2:SetOperation(c8240199.gvop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「青色眼睛的贤士」以外的光属性·1星调整怪兽
function c8240199.thfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1) and not c:IsCode(8240199) and c:IsAbleToHand()
end
-- ①效果的发动准备，检查卡组中是否存在符合条件的卡并设置检索的操作信息
function c8240199.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8240199.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为将卡组的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理，从卡组选择1只符合条件的怪兽加入手卡并给对方确认
function c8240199.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c8240199.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动代价，将此卡从手卡丢弃送去墓地
function c8240199.gvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡作为发动代价从手卡丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤自己场上表侧表示的效果怪兽，并考虑送去墓地后是否能腾出怪兽区域空格
function c8240199.gvfilter(c,ft)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave() and (ft>0 or c:GetSequence()<5)
end
-- 过滤卡组中可以特殊召唤的「青眼」怪兽
function c8240199.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备，检查怪兽区域空格、选择自己场上1只效果怪兽作为对象，并设置送去墓地和特殊召唤的操作信息
function c8240199.gvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家当前怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c8240199.gvfilter(chkc,ft) end
	-- 检查自己场上是否存在可以作为对象的表侧表示效果怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c8240199.gvfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 检查卡组中是否存在可以特殊召唤的「青眼」怪兽
		and Duel.IsExistingMatchingCard(c8240199.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c8240199.gvfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 设置当前连锁的操作信息为将对象怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置当前连锁的操作信息为从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理，将作为对象的怪兽送去墓地，若成功送去墓地则从卡组特殊召唤1只「青眼」怪兽
function c8240199.gvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送去墓地，并检查是否成功送去墓地
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
			-- 检查自己场上是否有可用的怪兽区域空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在可以特殊召唤的「青眼」怪兽
			and Duel.IsExistingMatchingCard(c8240199.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组中选择1张可以特殊召唤的「青眼」怪兽
			local g=Duel.SelectMatchingCard(tp,c8240199.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的「青眼」怪兽以表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
