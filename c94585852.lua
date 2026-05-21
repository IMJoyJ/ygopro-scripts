--万魔殿－悪魔の巣窟－
-- 效果：
-- 名称中含有「恶魔」字样的怪兽在准备阶段可以不必支付基本分。当名称中含有「恶魔」字样的怪兽由于战斗以外的方式被破坏送去墓地时，可以从卡组中选择1张等级比被破坏的怪兽等级低，且名称中含有「恶魔」字样的怪兽卡加入手卡。
function c94585852.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 名称中含有「恶魔」字样的怪兽在准备阶段可以不必支付基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(94585852)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c94585852.costcon)
	c:RegisterEffect(e2)
	-- 当名称中含有「恶魔」字样的怪兽由于战斗以外的方式被破坏送去墓地时，可以从卡组中选择1张等级比被破坏的怪兽等级低，且名称中含有「恶魔」字样的怪兽卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94585852,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_CUSTOM+94585852)
	e4:SetTarget(c94585852.target)
	e4:SetOperation(c94585852.operation)
	c:RegisterEffect(e4)
	if not c94585852.global_check then
		c94585852.global_check=true
		-- 当名称中含有「恶魔」字样的怪兽由于战斗以外的方式被破坏送去墓地时
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c94585852.regop)
		-- 在全局注册该全局监听效果，用于监控卡片送去墓地的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 不必支付基本分效果的适用条件函数
function c94585852.costcon(e)
	-- 判断当前阶段是否为准备阶段
	return Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 全局监听效果的处理函数，筛选因战斗以外被破坏送去墓地的「恶魔」怪兽，并记录其最高等级
function c94585852.regop(e,tp,eg,ep,ev,re,r,rp)
	local lv1=0
	local lv2=0
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	local tc=eg:GetFirst()
	while tc do
		if tc:IsReason(REASON_DESTROY) and not tc:IsReason(REASON_BATTLE) and tc:GetPreviousTypeOnField()&TYPE_MONSTER~=0
			and tc:IsSetCard(0x45) and tc:GetLevel()>0 then
			local tlv=tc:GetLevel()
			if tc:IsControler(0) then
				if tlv>lv1 then lv1=tlv end
				g1:AddCard(tc)
			else
				if tlv>lv2 then lv2=tlv end
				g2:AddCard(tc)
			end
		end
		tc=eg:GetNext()
	end
	-- 若玩家0有符合条件的怪兽被破坏，则触发自定义事件，传递怪兽组和最高等级作为参数
	if g1:GetCount()>0 then Duel.RaiseEvent(g1,EVENT_CUSTOM+94585852,re,r,rp,0,lv1) end
	-- 若玩家1有符合条件的怪兽被破坏，则触发自定义事件，传递怪兽组和最高等级作为参数
	if g2:GetCount()>0 then Duel.RaiseEvent(g2,EVENT_CUSTOM+94585852,re,r,rp,1,lv2) end
end
-- 过滤卡组中等级低于被破坏怪兽、且名称含有「恶魔」的怪兽卡
function c94585852.filter(c,lv)
	return c:GetLevel()<lv and c:IsSetCard(0x45) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动影响与合法性检测函数
function c94585852.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查卡组中是否存在符合条件的「恶魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94585852.filter,tp,LOCATION_DECK,0,1,nil,ev) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function c94585852.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张等级低于被破坏怪兽的「恶魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c94585852.filter,tp,LOCATION_DECK,0,1,1,nil,ev)
	if g:GetCount()>0 then
		-- 将选择的怪兽卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
