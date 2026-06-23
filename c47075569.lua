--EMペンデュラム・マジシャン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：自己场上有「娱乐伙伴」怪兽灵摆召唤的场合发动。自己场上的全部「娱乐伙伴」怪兽的攻击力直到回合结束时上升1000。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合，以自己场上最多2张卡为对象才能发动。那些卡破坏，把破坏数量的「娱乐伙伴 灵摆魔术家」以外的「娱乐伙伴」怪兽从卡组加入手卡（同名卡最多1张）。
function c47075569.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上有「娱乐伙伴」怪兽灵摆召唤的场合发动。自己场上的全部「娱乐伙伴」怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c47075569.atkcon)
	e2:SetOperation(c47075569.atkop)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合，以自己场上最多2张卡为对象才能发动。那些卡破坏，把破坏数量的「娱乐伙伴 灵摆魔术家」以外的「娱乐伙伴」怪兽从卡组加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,47075569)
	e3:SetTarget(c47075569.thtg)
	e3:SetOperation(c47075569.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查目标是否为正面表示的「娱乐伙伴」灵摆召唤的怪兽
function c47075569.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 条件函数：判断是否有满足cfilter条件的怪兽被特殊召唤成功
function c47075569.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47075569.cfilter,1,nil,tp)
end
-- 过滤函数：检查目标是否为正面表示的「娱乐伙伴」怪兽
function c47075569.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 效果处理函数：将场上所有「娱乐伙伴」怪兽的攻击力上升1000点直到回合结束
function c47075569.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有正面表示的「娱乐伙伴」怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c47075569.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 创建一个用于提升攻击力的效果并注册到目标怪兽上，提升值为1000点，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤函数：检查目标是否为「娱乐伙伴」怪兽且可以加入手牌
function c47075569.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and not c:IsCode(47075569) and c:IsAbleToHand()
end
-- 效果处理函数：选择场上目标卡并检索满足条件的「娱乐伙伴」怪兽加入手牌
function c47075569.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 判断是否满足选择破坏对象和检索卡组的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断是否满足检索卡组中符合条件的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c47075569.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取卡组中所有符合条件的「娱乐伙伴」怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c47075569.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct>2 then ct=2 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上最多2张卡作为破坏对象
	local dg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 设置操作信息：将破坏效果加入连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
	-- 设置操作信息：将检索效果加入连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,dg:GetCount(),tp,LOCATION_DECK)
end
-- 效果处理函数：执行破坏并检索卡组中符合条件的怪兽加入手牌
function c47075569.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片组，并筛选出与当前效果相关的卡片
	local dg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以破坏理由将目标卡片组进行破坏，返回实际破坏数量
	local ct=Duel.Destroy(dg,REASON_EFFECT)
	-- 获取卡组中所有符合条件的「娱乐伙伴」怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c47075569.thfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 or g:GetCount()==0 then return end
	if ct>g:GetClassCount(Card.GetCode) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从符合条件的卡组中选择指定数量且卡名不同的怪兽组成卡片组
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选定的怪兽以加入手牌理由送入手牌
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 向对方确认所选怪兽的卡面
	Duel.ConfirmCards(1-tp,g1)
end
