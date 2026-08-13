--ゼンマイハンター
-- 效果：
-- 自己的主要阶段时，把「发条猎人」以外的自己场上表侧表示存在的1只名字带有「发条」的怪兽解放才能发动。对方手卡随机1张送去墓地。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c16923472.initial_effect(c)
	-- 自己的主要阶段时，把「发条猎人」以外的自己场上表侧表示存在的1只名字带有「发条」的怪兽解放才能发动。对方手卡随机1张送去墓地。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16923472,0))  --"手牌破坏"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16923472.cost)
	e1:SetTarget(c16923472.target)
	e1:SetOperation(c16923472.operation)
	c:RegisterEffect(e1)
end
-- costfilter过滤函数：筛选出自己场上表侧表示、卡名带有「发条」字段、但卡名不是「发条猎人」的怪兽，作为可解放的代价候选。
function c16923472.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and not c:IsCode(16923472)
end
-- cost代价函数：先检查是否存在满足条件的可解放怪兽，若满足则让玩家选择1只解放作为发动代价，此解放为COST不进入连锁。
function c16923472.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost的chk==0检查：在发动前确认自己场上是否存在至少1只满足costfilter条件的可解放怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c16923472.costfilter,1,nil) end
	-- 让玩家从自己场上选择1只满足costfilter条件的怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c16923472.costfilter,1,1,nil)
	-- 将选择的那只怪兽解放，reason为REASON_COST，表示这是发动效果所支付的代价，不会被“不受效果影响”等抗性无效。
	Duel.Release(sg,REASON_COST)
end
-- target目标函数：发动时确认对方手牌是否有卡，若有则设置“将对方手牌送去墓地”的操作信息，不取对象，效果处理时随机选1张。
function c16923472.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- target的chk==0检查：确认对方手牌中存在至少1张卡，否则效果不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 end
	-- 将本次效果的操作信息登记为：把对方手牌中的1张卡送去墓地（CATEGORY_TOGRAVE），数量1，涉及对方手牌区域。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- operation处理函数：效果结算时，随机选择对方1张手牌送去墓地，若对方手牌为0则不处理。
function c16923472.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的手牌全体卡组对象，用于后续随机选择。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选出的对方手牌送去墓地，reason为REASON_EFFECT，属于效果处理导致送去墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
