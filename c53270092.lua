--キュウドウ魂 HAN－SHI
-- 效果：
-- ←9 【灵摆】 9→
-- ①：场上有怪兽灵摆召唤的场合发动。这张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时才能发动。和自己的灵摆区域的卡相同纵列的自己的卡全部回到持有者手卡。那之后，可以从卡组把「弓道魂 范士」以外的1只攻击力2400/守备力1000的怪兽加入手卡。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
local s,id,o=GetID()
-- 初始化效果：为这张卡注册灵摆怪兽属性、灵魂怪兽的回手效果，然后创建两个诱发效果——①在灵摆区时若场上有怪兽灵摆召唤则自身回手；②召唤成功时处理与灵摆区同纵列卡回手并可能检索。
function s.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽基本属性：可以进行灵摆召唤、作为魔法卡从手卡发动到灵摆区等。
	aux.EnablePendulumAttribute(c)
	-- 为这张卡添加灵魂怪兽的结束阶段回手效果：在召唤成功或反转的回合结束时回到持有者手卡。
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
-- 判定特殊召唤成功的怪兽中是否存在以灵摆召唤方式特殊召唤的怪兽，若有则灵摆效果满足发动条件。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
-- 发动时合法性检查直接通过；同时设置效果操作信息：将这张卡自身加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的处理信息：处理分类为回到手卡，目标为这张卡自身（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与当前效果有关联，则将其送回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以效果原因将这张卡送去其持有者的手卡。
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
-- 判定某张灵摆区卡所在纵列（包括该卡自身）是否存在可以被送回手卡的卡，作为该灵摆区卡能否成为处理对象的过滤条件。
function s.tgfilter(c,tp)
	local g=c:GetColumnGroup()
	g:AddCard(c)
	-- 检查自己场上是否存在属于该纵列组且满足可回手条件的卡（若存在则返回true）。注意这里的g包含了当前灵摆区卡自身。
	return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_ONFIELD,0,1,nil,g)
end
-- 过滤函数：指定的卡必须属于该纵列组，并且能够加入手卡。
function s.gyfilter(c,g)
	return g:IsContains(c) and c:IsAbleToHand()
end
-- 检索筛选条件：卡名不是「弓道魂 范士」，攻击力2400，守备力1000，且能加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsAttack(2400) and c:IsDefense(1000)
		and c:IsAbleToHand()
end
-- 怪兽效果①的目标函数：在发动时确认自己灵摆区存在可处理的灵摆卡，并登记效果操作信息为将对方场上的怪兽送去墓地（代码以此分类登记预定处理；实际结算时仍执行回手处理）。
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的条件检查：自己灵摆区是否存在满足tgfilter的卡，若无则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_PZONE,0,1,nil,tp) end
	-- 设置操作信息：将对方场上的怪兽送去墓地（此处category写为CATEGORY_TOGRAVE，表示该效果可能涉及送墓；星尘龙等会参考这一登记信息）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_MZONE)
end
-- 效果处理：检索并处理自己所有满足条件的灵摆区卡，收集它们同纵列（含自身）中可回手的卡全部回手；然后询问玩家是否从卡组检索符合条件的怪兽加入手卡。
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区中满足tgfilter条件的全部灵摆卡集合，作为效果处理对象。
	local pg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_PZONE,0,nil,tp)
	if pg:GetCount()==0 then return end
	local tg=Group.CreateGroup()
	-- 遍历这张灵摆区卡集合中的每一张卡，分别获取其同纵列的卡。
	for pc in aux.Next(pg) do
		local g=pc:GetColumnGroup()
		g:AddCard(pc)
		-- 将当前灵摆区卡及其同纵列中可回手的卡合并到总回收集合tg。
		tg:Merge(Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_ONFIELD,0,nil,g))
	end
	-- 如果待回手集合非空，且将回手操作实际成功执行（回手数量不为0），才继续后续的检索环节。
	if #tg>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0
		-- 并且卡组中存在符合检索条件的怪兽，才询问是否检索。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否要从卡组把符合条件的怪兽加入手卡（使用效果提示文字）。如果玩家选否，则不进行检索。
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把怪兽加入手卡？"
		-- 向玩家展示从卡组选择要加入手卡的卡片的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张符合s.thfilter条件的怪兽卡。
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果链的处理，使回手效果与后续检索视为不同时处理，避免引起错时点。
			Duel.BreakEffect()
			-- 以效果原因将选择检索到的卡加入其持有者手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 将检索加入手卡的卡展示给对手确认。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
