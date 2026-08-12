--胡蝶姉妹
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的怪兽的等级合计是对方场上的怪兽的等级合计以下的场合，把这张卡解放才能发动。从卡组把1只7星以上的昆虫族·植物族怪兽加入手卡，这个回合中，以下效果适用。
-- ●只要自己对这个效果加入手卡的怪兽或者原本卡名和那只怪兽相同的怪兽的召唤·特殊召唤不成功，结束阶段让自己受到2700伤害。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- ①：自己场上的怪兽的等级合计是对方场上的怪兽的等级合计以下的场合，把这张卡解放才能发动。从卡组把1只7星以上的昆虫族·植物族怪兽加入手卡，这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上的怪兽等级合计在对方场上的怪兽等级合计以下
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有表侧表示的怪兽
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return g1:GetSum(Card.GetLevel)<=g2:GetSum(Card.GetLevel)
end
-- 效果发动代价：把这张卡解放
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中等级7以上、昆虫族或植物族且可以加入手牌的怪兽
function s.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsAbleToHand()
end
-- 效果发动目标：从卡组将1只满足条件的怪兽加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只满足条件的怪兽加入手牌，并注册未成功召唤时的伤害效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- ●只要自己对这个效果加入手卡的怪兽或者原本卡名和那只怪兽相同的怪兽的召唤·特殊召唤不成功，结束阶段让自己受到2700伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetOperation(s.regop)
		e1:SetLabel(g:GetFirst():GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册用于检测通常召唤成功事件的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetLabelObject(e1)
		-- 注册用于检测特殊召唤成功事件的全局效果
		Duel.RegisterEffect(e2,tp)
		-- ●只要自己对这个效果加入手卡的怪兽或者原本卡名和那只怪兽相同的怪兽的召唤·特殊召唤不成功，结束阶段让自己受到2700伤害。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetCondition(s.damcon)
		e3:SetOperation(s.damop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetLabelObject(e2)
		-- 注册在结束阶段触发伤害判定的全局效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 召唤成功时的处理：若召唤的怪兽与加入手牌的怪兽同名，则清除未召唤标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	local tc=eg:GetFirst()
	if tc:IsSummonPlayer(tp) and tc:IsCode(e:GetLabel()) then
		e:SetLabel(0)
	end
end
-- 结束阶段伤害效果的触发条件：未成功进行该怪兽的通常召唤或特殊召唤
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local lo=e:GetLabelObject()
	return lo:GetLabel()~=0 and lo:GetLabelObject():GetLabel()~=0
end
-- 结束阶段伤害效果的处理：给与玩家2700点伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动伤害效果的卡片
	Duel.Hint(HINT_CARD,0,id)
	-- 给与玩家2700点效果伤害
	Duel.Damage(tp,2700,REASON_EFFECT)
end
