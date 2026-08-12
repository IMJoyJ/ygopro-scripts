--贖いのエンブレーマ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己的魔法与陷阱区域1张表侧表示的「百夫长骑士」怪兽卡除外，以对方场上1张卡为对象才能发动。那张卡除外。
-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。自己的手卡·卡组·墓地·除外状态的2只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置（同名卡最多1张）。
local s,id,o=GetID()
-- 初始化函数：注册卡片的发动效果（e1）、被破坏时的诱发效果（e2）以及被除外时的诱发效果（e3）
function s.initial_effect(c)
	-- ①：把自己的魔法与陷阱区域1张表侧表示的「百夫长骑士」怪兽卡除外，以对方场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。自己的手卡·卡组·墓地·除外状态的2只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"表侧表示放置"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己魔陷区表侧表示的、原本是怪兽卡的「百夫长骑士」卡片，且可以作为Cost除外
function s.cfilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER
		and c:IsSetCard(0x1a2) and c:IsAbleToRemoveAsCost()
end
-- ①号效果的Cost：将自己魔陷区1张表侧表示的「百夫长骑士」怪兽卡除外
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否存在满足Cost条件的「百夫长骑士」怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1张满足Cost条件的「百夫长骑士」怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡作为Cost表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①号效果的对象与发动准备：确认对方场上是否有可除外的卡，并进行取对象和设置操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在可以被除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可以被除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：除外选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①号效果的处理：将作为对象的卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②号效果的发动条件：盖放的这张卡因对方发动的效果而被破坏或除外
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and re:IsActivated()
end
-- 过滤条件：手卡、卡组、墓地、除外状态的「百夫长骑士」怪兽卡
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②号效果的发动准备：检查各区域是否存在至少2种不同名的「百夫长骑士」怪兽，且自己魔陷区有2个以上的空位
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡、卡组、墓地、除外状态中所有满足条件的「百夫长骑士」怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2
		-- 检查自己魔陷区是否有2个以上的空位，且本连锁中该效果未被重复触发
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 and e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
-- ②号效果的处理：选择2只不同名的「百夫长骑士」怪兽，当作永续陷阱卡在自己的魔陷区表侧表示放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔陷区的可用空格数
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ct<2 then return end
	-- 获取手卡、卡组、墓地、除外状态中所有满足条件且不受王家长眠之谷影响的「百夫长骑士」怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家选择2张卡名不同的「百夫长骑士」怪兽
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 遍历选中的2张卡
	for tc in aux.Next(tg1) do
		-- 将选中的怪兽在自己的魔法与陷阱区域表侧表示放置
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续陷阱卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
