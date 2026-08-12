--再世の魔神 ベミドバル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以把攻击力或守备力是2500的手卡1只其他怪兽给对方观看，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。「再世之魔神 必密巴」以外的自己的卡组·除外状态的1张「再世」卡加入手卡。
-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册手卡特召规则、召唤/特召成功时检索效果、送墓时注册标志效果以及对方回合结束阶段回收效果。
function s.initial_effect(c)
	-- ①：这张卡可以把攻击力或守备力是2500的手卡1只其他怪兽给对方观看，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。「再世之魔神 必密巴」以外的自己的卡组·除外状态的1张「再世」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的对方回合的结束阶段才能发动。这张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"回收"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.thcon2)
	e5:SetTarget(s.thtg2)
	e5:SetOperation(s.thop2)
	c:RegisterEffect(e5)
end
-- 过滤条件：手卡中攻击力或守备力是2500的非公开怪兽。
function s.spcfilter(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 特殊召唤规则的发动条件：自己场上有可用的怪兽区域，且手卡有满足条件的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除这张卡以外的、满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
end
-- 特殊召唤规则的选择目标：选择手卡中1只满足条件的怪兽作为给对方观看的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除这张卡以外的、满足过滤条件的怪兽组。
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行：将选择的怪兽给对方观看，并洗牌。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手牌。
	Duel.ShuffleHand(tp)
end
-- 过滤条件：卡组或除外状态的「再世之魔神 必密巴」以外的「再世」卡。
function s.thfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c5) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组或除外状态是否存在满足条件的卡，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或除外状态是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：从卡组或除外状态将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- 效果②的效果处理：从卡组或除外状态选择1张满足条件的卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或除外状态选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 注册标志效果：在这张卡送去墓地的回合的结束阶段前，为这张卡注册一个带有该卡号的Flag。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③的发动条件：当前回合是对方回合，且这张卡在当前回合被送去过墓地（持有对应的Flag）。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前是否为对方回合，且这张卡在当前回合被送去过墓地。
	return Duel.GetTurnPlayer()==1-tp and e:GetHandler():GetFlagEffect(id)>0
end
-- 效果③的发动准备：检查这张卡是否可以加入手牌，并设置回收的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地的这张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：将墓地的这张卡加入手牌。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，且不受「王家长眠之谷」的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手牌的这张卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
	end
end
