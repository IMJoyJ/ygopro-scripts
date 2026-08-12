--ワンチャン！？
-- 效果：
-- ①：自己场上有1星怪兽存在的场合才能发动。从卡组把1只1星怪兽加入手卡，这个回合中，以下效果适用。
-- ●只要自己对这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，结束阶段让自己受到2000伤害。
local s,id,o=GetID()
-- 创建并注册主效果，设置为自由连锁发动，条件为己方场上存在1星怪兽，目标为从卡组检索1只1星怪兽加入手牌，效果处理为激活效果
function s.initial_effect(c)
	-- ①：自己场上有1星怪兽存在的场合才能发动。从卡组把1只1星怪兽加入手卡，这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断场上是否存在1星怪兽的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(1)
end
-- 判断己方场上是否存在1星怪兽的效果条件函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只1星怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选卡组中可加入手牌的1星怪兽的过滤函数
function s.filter(c)
	return c:IsLevel(1) and c:IsAbleToHand()
end
-- 设置效果目标，检查卡组中是否存在满足条件的1星怪兽，并设置操作信息为检索1张卡到手牌
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果发动条件，即卡组中存在至少1只1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为1张加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并检索1只1星怪兽到手牌，并注册后续触发效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的1星怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选怪兽
		Duel.ConfirmCards(1-tp,g)
		-- ●只要自己对这个效果加入手卡的怪兽或者那些同名卡的召唤不成功，结束阶段让自己受到2000伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetOperation(s.regop)
		e1:SetLabel(g:GetFirst():GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册召唤成功时触发的效果，用于记录是否召唤失败
		Duel.RegisterEffect(e1,tp)
		-- 注册结束阶段触发的效果，用于判定是否造成伤害
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetCondition(s.damcon)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		-- 注册结束阶段触发的伤害效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 处理召唤成功的回调函数，标记该怪兽是否被成功召唤
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	local tc=eg:GetFirst()
	if tc:IsSummonPlayer(tp) and tc:IsCode(e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 判断是否需要造成伤害的条件函数
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=0
end
-- 造成2000点伤害的效果处理函数
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了该卡
	Duel.Hint(HINT_CARD,0,id)
	-- 对玩家造成2000点伤害
	Duel.Damage(tp,2000,REASON_EFFECT)
end
