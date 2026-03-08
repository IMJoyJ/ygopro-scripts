--サイバーダーク・インフェルノ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：有装备卡装备的自己场上的「电子暗黑」效果怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：以自己场上1只「电子暗黑」怪兽为对象才能发动。那只怪兽回到持有者手卡，那之后可以把1只「电子暗黑」怪兽召唤。
-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c44352516.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：有装备卡装备的自己场上的「电子暗黑」效果怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c44352516.indestg)
	-- 设置效果值为aux.indoval函数，用于判断是否不会被对方效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果值为aux.tgoval函数，用于判断是否不会成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：以自己场上1只「电子暗黑」怪兽为对象才能发动。那只怪兽回到持有者手卡，那之后可以把1只「电子暗黑」怪兽召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,44352516)
	e4:SetTarget(c44352516.target)
	e4:SetOperation(c44352516.operation)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c44352516.thcon)
	e5:SetTarget(c44352516.thtg)
	e5:SetOperation(c44352516.thop)
	c:RegisterEffect(e5)
end
-- 过滤函数，判断目标怪兽是否为「电子暗黑」效果怪兽且有装备卡
function c44352516.indestg(e,c)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_EFFECT) and c:GetEquipCount()>0
end
-- 过滤函数，判断目标怪兽是否为「电子暗黑」怪兽且表侧表示且能送入手牌
function c44352516.filter(c)
	return c:IsSetCard(0x4093) and c:IsFaceup() and c:IsAbleToHand()
end
-- 过滤函数，判断目标怪兽是否为「电子暗黑」怪兽且能通常召唤
function c44352516.filter2(c)
	return c:IsSetCard(0x4093) and c:IsSummonable(true,nil)
end
-- 设置效果目标为己方场上的「电子暗黑」怪兽，用于效果处理
function c44352516.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44352516.filter(chkc) end
	-- 检查是否满足效果发动条件，即己方场上存在符合条件的「电子暗黑」怪兽
	if chk==0 then return Duel.IsExistingTarget(c44352516.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽，数量为1
	local g=Duel.SelectTarget(tp,c44352516.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽送入手牌并询问是否召唤怪兽
function c44352516.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功送入手牌
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取己方手牌和场上的「电子暗黑」怪兽，用于召唤
		local g=Duel.GetMatchingGroup(c44352516.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		-- 判断是否有符合条件的怪兽且玩家选择召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(44352516,0)) then  --"是否把「电子暗黑」怪兽召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			local sg=g:Select(tp,1,1,nil):GetFirst()
			-- 执行召唤操作
			Duel.Summon(tp,sg,true,nil)
		end
	end
end
-- 判断效果是否由对方发动且破坏了此卡
function c44352516.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and bit.band(r,0x41)==0x41
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，判断目标卡是否为「融合」魔法卡
function c44352516.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果目标为卡组中的「融合」魔法卡
function c44352516.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果发动条件，即卡组中存在符合条件的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44352516.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将1张「融合」魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，从卡组选择1张「融合」魔法卡加入手牌
function c44352516.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,c44352516.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
