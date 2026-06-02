--超魔剣士ブラック・カオス
-- 效果：
-- 这张卡不能通常召唤。「超魔剑士 黑混沌」1回合1次在从自己的手卡·墓地让1只魔法师族·战士族的仪式怪兽回到卡组的场合才能特殊召唤。
-- ①：把这张卡从手卡丢弃才能发动。从自己的卡组·墓地把有「光与暗的仪式」的卡名记述的1张永续陷阱卡在自己场上表侧表示放置。
-- ②：只要自己墓地有仪式魔法卡存在，这张卡不受对方发动的效果影响。
-- ③：1回合1次，自己主要阶段才能发动。对方场上2张卡除外。
local s,id,o=GetID()
-- 初始化怪兽卡效果：添加记载卡密码列表，设置特殊召唤条件，注册特殊召唤规则、丢弃手卡放置魔陷效果、效果免疫效果以及除外卡片的效果
function s.initial_effect(c)
	-- 建立这张卡记述了卡片密码为33599853（光与暗的仪式）的关联列表
	aux.AddCodeList(c,33599853)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「超魔剑士 黑混沌」1回合1次在从自己的手卡·墓地让1只魔法师族·战士族的仪式怪兽回到卡组的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.sprcon)
	e2:SetTarget(s.sprtg)
	e2:SetOperation(s.sprop)
	c:RegisterEffect(e2)
	-- ①：把这张卡从手卡丢弃才能发动。从自己的卡组·墓地把有「光与暗的仪式」的卡名记述的1张永续陷阱卡在自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(s.tfcost)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
	-- ②：只要自己墓地有仪式魔法卡存在，这张卡不受对方发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.imcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己主要阶段才能发动。对方场上2张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"除外"
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
-- 过滤函数：检索手卡或墓地中可以作为特殊召唤Cost放回卡组的魔法师族或战士族仪式怪兽
function s.sprfilter(c)
	return c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) and c:IsAbleToDeckAsCost()
end
-- 特殊召唤规则的Condition函数，检查主要怪兽区是否有空位以及是否有满足条件的怪兽用于特殊召唤的代价
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区域是否可以容纳特殊召唤的怪兽
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在满足特殊召唤代价条件的怪兽
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的Target函数，让玩家选择用于放回卡组的怪兽，并保存为效果标签对象
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取符合特殊召唤代价条件的所有怪兽卡片组
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:CancelableSelect(tp,1,1,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数，确认所选怪兽，将其送回卡组并洗卡，以此满足特殊召唤的代价
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 如果是手牌中的卡片，则向对方玩家展示这些选中的卡片
		Duel.ConfirmCards(1-tp,g:Filter(Card.IsLocation,nil,LOCATION_HAND))
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 如果是墓地中的卡片，则给这些卡片显示被选为对象的动画
		Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_GRAVE))
	end
	-- 将选中的卡片放回卡组并进行洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 手卡丢弃发动效果的Cost函数，检查并将自身送入墓地
function s.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为Cost将这张卡从手卡送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检索卡组或墓地中记述了「光与暗的仪式」卡名且可以表侧表示放置到场上的永续陷阱卡
function s.pfilter(c,tp)
	-- 判断卡片是否为永续陷阱卡，且在卡组中记述了「光与暗的仪式」
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and aux.IsCodeListed(c,33599853)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 手卡丢弃放置永续陷阱卡效果的Target函数，检查自己场上的魔陷区空位，以及是否存在能放置的目标
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或墓地中是否存在可供放置的满足条件的永续陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 手卡丢弃放置永续陷阱卡效果的Operation函数，在场上有空位时，让玩家选择满足条件的永续陷阱卡并表侧表示放置到场上
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查并确保自己场上的魔法与陷阱区域有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家发送请选择要放置到场上的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组或墓地选择1张不受王长谷影响的、满足条件的永续陷阱卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	-- 将选择的卡片在自己场上的魔法与陷阱区域表侧表示放置
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 过滤函数：检索墓地中的仪式魔法卡
function s.cfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL)
end
-- 效果免疫的Condition函数，检查自己墓地中是否存在仪式魔法卡
function s.imcon(e)
	-- 判断玩家墓地中是否存在至少1张仪式魔法卡
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 效果免疫的Value函数，使这张卡不受对方发动的效果影响
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 除外效果的Target函数，检查对方场上是否至少有2张可以除外的卡，并设置操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否至少存在2张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 获取对方场上所有可以除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 设置本效果包含将对方场上2张卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 除外效果的Operation函数，让玩家选择对方场上的2张卡并将其除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认对方场上是否依然存在至少2张可被除外的卡，若不足则不处理
	if not Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,nil) then return end
	-- 向玩家发送请选择要除外的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上正好2张可除外的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,2,nil)
	if #sg>0 then
		-- 为选择的卡片显示被选中的动画
		Duel.HintSelection(sg)
		-- 将选择的卡片表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
