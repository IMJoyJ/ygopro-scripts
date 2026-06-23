--地縛戒隷 ジオクラーケン
-- 效果：
-- 「地缚」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张场地魔法卡加入手卡。
-- ②：从对方的额外卡组有怪兽特殊召唤的场合才能发动。把这个回合特殊召唤的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×800伤害。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件并注册两个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个「地缚」怪兽作为融合素材
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
-- 定义场地魔法卡的过滤条件：类型为场地魔法且能加入手牌
function s.filter(c)
	return c:GetType()==TYPE_FIELD+TYPE_SPELL and c:IsAbleToHand()
end
-- 效果处理时点，检查是否存在满足条件的场地魔法卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将1张场地魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理时点，选择并执行将场地魔法卡加入手牌的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的场地魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义对方怪兽从额外卡组特殊召唤的过滤条件
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 判断是否有对方怪兽从额外卡组特殊召唤
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 效果处理时点，检查是否有对方回合特殊召唤的怪兽并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方回合特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	if chk==0 then return #g>0 end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：破坏对方回合特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置操作信息：对对方造成破坏怪兽数量×800的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*800)
end
-- 效果处理时点，执行破坏对方回合特殊召唤的怪兽并造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方回合特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,0,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	-- 将对方回合特殊召唤的怪兽全部破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 如果破坏了怪兽，则对对方造成相应数量×800的伤害
	if ct>0 then Duel.Damage(1-tp,ct*800,REASON_EFFECT) end
end
