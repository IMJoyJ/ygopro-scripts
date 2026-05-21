--決闘進化－バスター・ゾーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把有「爆裂模式」的卡名记述的1只怪兽加入手卡。
-- ②：「/爆裂体」怪兽在特殊召唤的回合不会被战斗以及对方的效果破坏。
-- ③：支付2000基本分才能发动。这个回合只有1次，可以从额外卡组选自己要为「爆裂模式」发动而解放的同调怪兽。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果的发动、②效果的战斗与效果破坏抗性、③效果的起动效果。
function s.initial_effect(c)
	-- 将「爆裂模式」的卡片密码（80280737）注册到该卡的关联卡片列表中。
	aux.AddCodeList(c,80280737)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地把有「爆裂模式」的卡名记述的1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：「/爆裂体」怪兽在特殊召唤的回合不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：「/爆裂体」怪兽在特殊召唤的回合不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	-- 设置抗性来源为对方玩家发动的卡的效果。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：支付2000基本分才能发动。这个回合只有1次，可以从额外卡组选自己要为「爆裂模式」发动而解放的同调怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"额外解放"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.cost)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
-- 过滤满足检索条件的怪兽的辅助函数。
function s.thfilter(c)
	-- 过滤出文本中记述有「爆裂模式」且可以加入手牌的怪兽卡。
	return aux.IsCodeListed(c,80280737) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果（卡片发动时的效果处理）的执行函数，处理检索或回收。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组及墓地中满足过滤条件且不受王家之谷影响的卡片组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 如果存在满足条件的卡，则询问玩家是否选择加入手牌。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否检索怪兽？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 破坏抗性效果的适用对象过滤函数，仅适用于本回合特殊召唤的「/爆裂体」怪兽。
function s.indtg(e,c)
	return c:IsSetCard(0x104f) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- ③效果的发动代价（Cost）处理函数。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分，且本回合尚未注册该效果的全局标识。
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.GetFlagEffect(tp,91002901)==0 end
	-- 扣除玩家2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- ③效果的执行函数，用于注册全局标识。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册一个持续到回合结束的全局标识，用于允许从额外卡组选怪兽作为「爆裂模式」的解放。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
