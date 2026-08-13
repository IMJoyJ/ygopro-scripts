--地縛戒隷 ジオクラーケン
-- 效果：
-- 「地缚」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张场地魔法卡加入手卡。
-- ②：从对方的额外卡组有怪兽特殊召唤的场合才能发动。把这个回合特殊召唤的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×800伤害。
local s,id,o=GetID()
-- 定义这张卡的初始效果注册函数：赋予苏生限制，添加融合召唤手续（2只“地缚”怪兽），并注册①检索效果和②破坏伤害效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用2只满足“地缚”字段条件的怪兽作为融合素材，允许进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x21),2,true)
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：从对方的额外卡组有怪兽特殊召唤的场合才能发动。把这个回合特殊召唤的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×800伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤的对方怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤条件：筛选类型为场地魔法且能够加入手卡的卡。
function s.filter(c)
	return c:GetType()==TYPE_FIELD+TYPE_SPELL and c:IsAbleToHand()
end
-- ①效果的发动条件和操作信息登记：确认自己卡组·墓地存在符合条件的场地魔法卡，然后向对方提示效果发动，并登记检索加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若自己卡组·墓地中不存在符合条件的场地魔法卡，则该效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示“对方选择了该效果”，显示对应的效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记操作信息：从自己卡组·墓地中检索1张卡加入手卡，目标位置为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从自己卡组·墓地选择1张符合条件的场地魔法卡加入手卡，并展示给对方确认；同时不受王家长眠之谷影响的卡才能被选择。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地中选择1张满足条件且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的触发筛选条件：判断特殊召唤的怪兽是否曾被对方控制，并且是从额外卡组特殊召唤。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：当有从对方额外卡组特殊召唤的怪兽成功时，满足发动条件。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- ②效果的发动条件和操作信息登记：获取对方场上本回合特殊召唤的怪兽，若存在则提示对方，并登记破坏和伤害信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有在本回合被特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	if chk==0 then return #g>0 end
	-- 向对方玩家提示“对方选择了该效果”，显示对应的效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记破坏操作信息：将上述怪兽全部破坏，数量为这些怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 登记伤害操作信息：预计给对方造成#g×800点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*800)
end
-- ②效果处理：重新获取对方场上本回合特殊召唤的怪兽，将其全部破坏，并按实际破坏数量给对方造成伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有在本回合被特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	-- 以效果原因破坏这些怪兽，返回实际被破坏的数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 若实际破坏数量大于0，则给对方造成破坏数量×800点的效果伤害。
	if ct>0 then Duel.Damage(1-tp,ct*800,REASON_EFFECT) end
end
