--TG－オールクリア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：场上的「科技属」怪兽变成机械族。
-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「科技属」怪兽召唤。
-- ③：自己主要阶段才能发动。自己的手卡·场上1只「科技属」怪兽破坏，和那只怪兽卡名不同的1只「科技属」怪兽从自己的卡组·墓地加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果（发动、种族改变、追加召唤、破坏并检索）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「科技属」怪兽变成机械族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤受影响的卡片，目标为「科技属」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x27))
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「科技属」怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"使用「科技属-全部通过」的效果召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 过滤可以追加召唤的怪兽，目标为「科技属」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x27))
	c:RegisterEffect(e3)
	-- ③：自己主要阶段才能发动。自己的手卡·场上1只「科技属」怪兽破坏，和那只怪兽卡名不同的1只「科技属」怪兽从自己的卡组·墓地加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
-- 过滤手卡·场上可被破坏的「科技属」怪兽，且卡组·墓地中必须存在至少1只与其卡名不同的「科技属」怪兽
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER)
		-- 检查自己的卡组或墓地中是否存在至少1张与被破坏怪兽卡名不同的、可加入手牌的「科技属」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 过滤卡组·墓地中可加入手牌的「科技属」怪兽，且其卡名不能与传入的参数（被破坏怪兽的卡名）相同
function s.filter(c,...)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and (#{...}==0 or not c:IsCode(...))
end
-- ③效果的发动准备与合法性检测，检查手卡·场上是否有可破坏的「科技属」怪兽，并设置破坏与检索的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡及怪兽区中所有满足破坏条件的「科技属」怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
	if chk==0 then return #g>0 end
	-- 设置破坏操作的信息，表示将破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置检索/回收操作的信息，表示将从卡组或墓地把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ③效果的实际处理逻辑：选择并破坏1只「科技属」怪兽，然后从卡组或墓地将1只不同名的「科技属」怪兽加入手牌
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手卡或场上选择1只满足条件的「科技属」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	-- 破坏选中的怪兽，若破坏失败则不进行后续处理
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1只与被破坏怪兽卡名不同的「科技属」怪兽（适用墓地效果时受王家长眠之谷影响）
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,g:GetFirst():GetCode())
	if #sg>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
