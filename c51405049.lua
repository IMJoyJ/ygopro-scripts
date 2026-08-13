--ワンチャン！？
-- 效果：
-- ①：自己场上有1星怪兽存在的场合才能发动。从卡组把1只1星怪兽加入手卡，这个回合中，以下效果适用。
-- ●只要自己对这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，结束阶段让自己受到2000伤害。
local s,id,o=GetID()
-- 初始化本卡效果：创建1个魔法卡发动效果e1，设置为手牌检索/加入类别，自由时点发动，并注册到本卡上。
function s.initial_effect(c)
	-- ①：自己场上有1星怪兽存在的场合才能发动。从卡组把1只1星怪兽加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于判定场上怪兽是否为表侧表示且等级为1。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(1)
end
-- 发动条件：检查自己场上是否存在至少1张表侧表示且等级为1的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在至少1张满足表侧1星条件的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：用于筛选卡组中等级为1且可以加入手卡的怪兽。
function s.filter(c)
	return c:IsLevel(1) and c:IsAbleToHand()
end
-- 发动时目标处理：若卡组存在符合条件的1星怪兽则可发动，并设置操作信息为从卡组将1张卡加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 卡组中必须存在至少1张可加入手卡的1星怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：从卡组把1张卡加入手卡（不取对象，检索类）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择卡组中1只1星怪兽加入手卡并向对方展示；随后注册2个持续效果：监测该怪兽或其同名卡是否被召唤成功；若结束阶段仍未召唤成功则自己受到2000伤害。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的1星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的1星怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 这个回合中，以下效果适用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetOperation(s.regop)
		e1:SetLabel(g:GetFirst():GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将用于监测召唤成功的持续效果e1注册到tp方，e1会在每次召唤成功时触发。
		Duel.RegisterEffect(e1,tp)
		-- ●只要自己对这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，结束阶段让自己受到2000伤害。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetCondition(s.damcon)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		-- 将结束阶段造成伤害的持续效果e2注册到tp方，该效果在结束阶段若条件满足则执行伤害。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 召唤成功时点：若当前召唤的怪兽由tp玩家召唤，且卡号与标记的卡号相同（即加入手卡的那只或其同名卡），则将标记置0，表示已成功召唤，结束阶段不再受伤。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	local tc=eg:GetFirst()
	if tc:IsSummonPlayer(tp) and tc:IsCode(e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 伤害判定条件：标记不为0，说明该怪兽或其同名卡还没有成功召唤，因此需要在结束阶段受伤。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 伤害效果处理：先展示本卡动画，然后给予tp玩家2000点效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示本卡的卡片动画/提示，表示接下来适用本卡的效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 给予效果发动者tp 2000点效果伤害（即自己受到2000伤害）。
	Duel.Damage(tp,2000,REASON_EFFECT)
end
