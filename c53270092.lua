--キュウドウ魂 HAN－SHI
-- 效果：
-- ←9 【灵摆】 9→
-- ①：场上有怪兽灵摆召唤的场合发动。这张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的自己的卡全部回到持有者手卡。那之后，可以从卡组把「弓道魂 范士」以外的1只攻击力2400/守备力1000的怪兽加入手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
local s,id,o=GetID()
-- 初始化效果，为卡片添加灵摆属性和灵魂怪兽效果，注册两个触发效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- 为卡片添加灵魂怪兽效果，在召唤或翻转成功后的结束阶段回到手卡
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- ①：场上有怪兽灵摆召唤的场合发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的自己的卡全部回到持有者手卡。那之后，可以从卡组把「弓道魂 范士」以外的1只攻击力2400/守备力1000的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
-- 判断是否有怪兽通过灵摆召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
-- 设置效果处理时的操作信息，准备将自身送回手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将自身送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将自身送回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身送回手牌
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
-- 过滤函数，判断灵摆区域的卡是否能影响场上其他卡
function s.tgfilter(c,tp)
	local g=c:GetColumnGroup()
	g:AddCard(c)
	-- 检查场上是否存在满足条件的卡
	return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_ONFIELD,0,1,nil,g)
end
-- 过滤函数，判断是否为同纵列且可送回手牌的卡
function s.gyfilter(c,g)
	return g:IsContains(c) and c:IsAbleToHand()
end
-- 过滤函数，判断是否为「弓道魂 范士」以外、攻击力2400/守备力1000的怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsAttack(2400) and c:IsDefense(1000)
		and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，准备将目标怪兽送去墓地
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_PZONE,0,1,nil,tp) end
	-- 设置操作信息为将对方场上怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 召唤成功时的效果处理函数，执行送回手牌和检索操作
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取灵摆区域中满足条件的卡组
	local pg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_PZONE,0,nil,tp)
	if pg:GetCount()==0 then return end
	local tg=Group.CreateGroup()
	-- 遍历灵摆区域中的每张卡
	for pc in aux.Next(pg) do
		local g=pc:GetColumnGroup()
		g:AddCard(pc)
		-- 获取与当前卡同纵列且可送回手牌的场上卡组
		tg:Merge(Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_ONFIELD,0,nil,g))
	end
	-- 判断是否有符合条件的卡被送回手牌
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0
		-- 检查卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组加入怪兽到手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择一张符合条件的怪兽加入手牌
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将选中的怪兽送回手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 确认对方查看所选怪兽
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
