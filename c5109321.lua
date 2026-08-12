--R.B.ジャンプ・ナンバー
-- 效果：
-- 这张卡发动的回合，自己若非原本攻击力是1500以下的机械族怪兽则不能从额外卡组特殊召唤。
-- ①：同名卡不在自己场上存在的1只「反叛曲机器人」怪兽从卡组·额外卡组特殊召唤。
-- ②：自己场上的「反叛曲机器人」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 注册卡片效果：e1为魔陷发动型的自由时点特殊召唤效果，e2为墓地发动的破坏代替永续效果，并注册额外卡组特殊召唤的活动计数器
function s.initial_effect(c)
	-- ①：同名卡不在自己场上存在的1只「反叛曲机器人」怪兽从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「反叛曲机器人」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	-- 注册特殊召唤活动计数器，用于检测本回合是否已用非原本攻击力1500以下的机械族怪兽从额外卡组特殊召唤过
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：若非从额外卡组特殊召唤，或是原本攻击力1500以下的机械族怪兽，则不计入限制次数
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500
end
-- cost函数：先检查本回合是否未进行过受限特殊召唤，然后注册持续至回合结束的誓约效果，禁止自己从额外卡组特殊召唤不符合条件的怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：本回合自己没有进行过受限的从额外卡组的特殊召唤才能发动
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己若非原本攻击力是1500以下的机械族怪兽则不能从额外卡组特殊召唤。①：同名卡不在自己场上存在的1只「反叛曲机器人」怪兽从卡组·额外卡组特殊召唤。②：自己场上的「反叛曲机器人」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把该誓约限制效果作为玩家效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤函数：若怪兽位于额外卡组且不是原本攻击力1500以下的机械族怪兽，则禁止其特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500)
end
-- 特殊召唤过滤函数：选择1只「反叛曲机器人」怪兽，要求可特殊召唤、满足誓约限制、自己场上不存在同名卡，且有可用的怪兽区
function s.spfilter(c,e,tp,cost)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not cost or not s.splimit(e,c))
		-- 要求自己场上不存在同名卡（表侧表示的同名卡不在自己场上存在）
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		-- 若从卡组特殊召唤，则需自己的主要怪兽区有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若从额外卡组特殊召唤，则须有能让额外卡组怪兽出场的可用怪兽区
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- target函数：发动条件检查自己的卡组·额外卡组是否存在可特殊召唤的「反叛曲机器人」怪兽，并设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：检查自己的卡组·额外卡组是否存在至少1只满足条件的「反叛曲机器人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,e:IsCostChecked()) end
	-- 设置操作信息：本连锁将进行从卡组·额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- activate函数：提示选择要特殊召唤的卡，让玩家从卡组·额外卡组选择1只满足条件的怪兽并将其特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送「请选择要特殊召唤的卡」的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组·额外卡组选择1只满足特殊召唤条件的「反叛曲机器人」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,false)
	if g:GetCount()>0 then
		-- 把选中的那只怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏代替过滤函数：自己场上表侧表示的「反叛曲机器人」怪兽被战斗·效果破坏时适用（已适用破坏代替的除外）
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 破坏代替发动条件：墓地的这张卡可以除外，且被破坏的怪兽中存在满足条件的「反叛曲机器人」怪兽，并询问玩家是否适用
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否适用破坏代替效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判定被破坏的怪兽是否为满足代替条件的自己场上「反叛曲机器人」怪兽
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 破坏代替处理：把墓地的这张卡除外
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因把墓地的这张卡表侧除外，作为破坏的代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
