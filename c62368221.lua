--浄化と腐敗のアルス＝マグナ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡除外才能发动。从卡组把1张「无垢大艺术」魔法·陷阱卡加入手卡。直到下个回合的结束时，自己的「狱神」连接怪兽在1回合各有最多3次不会被战斗破坏。
-- ②：这张卡是除外状态，超量·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
-- ③：以最多有自己场上的「狱神」连接怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡除外。
local s,id,o=GetID()
-- 初始化并注册这张卡的3个效果：①手卡除外后检索「无垢大艺术」魔法·陷阱卡的起动效果，②除外状态时在超量·连接怪兽特殊召唤成功的场合自身特殊召唤的诱发效果，③取场上魔法·陷阱卡为对象除外的起动效果，以及在被赋予二速化时③的诱发即时版本（e4克隆e3）
function s.initial_effect(c)
	-- ①：把这张卡从手卡除外才能发动。从卡组把1张「无垢大艺术」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡是除外状态，超量·连接怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：以最多有自己场上的「狱神」连接怪兽数量的场上的魔法·陷阱卡为对象才能发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.rmcon1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.rmcon2)
	c:RegisterEffect(e4)
end
-- ①效果的发动代价处理：把这张卡从手卡除外
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将这张卡以表侧表示除外作为发动代价
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 检索过滤条件：「无垢大艺术」系列的魔法·陷阱卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1e6) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的目标检查：确认卡组存在可加入手卡的「无垢大艺术」魔法·陷阱卡，并设置从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己卡组是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选1张「无垢大艺术」魔法·陷阱卡加入手卡并向对方确认，然后注册直到下个回合结束时自己「狱神」连接怪兽最多3次不会被战斗破坏的耐性效果及其适用中提示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 直到下个回合的结束时，自己的「狱神」连接怪兽在1回合各有最多3次不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.indct)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将战斗破坏耐性效果注册为玩家效果
	Duel.RegisterEffect(e1,tp)
	-- 这个卡名的①②③的效果1回合各能使用1次。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,3))  --"「净化与腐败之无垢大艺术」效果适用中"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(id)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将「净化与腐败之无垢大艺术」效果适用中的客户端提示注册为玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 耐性效果的作用对象：自己怪兽区域的「狱神」连接怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 破坏原因包含战斗时返回3，即每回合各有最多3次不会被战斗破坏
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 3
	else return 0 end
end
-- 过滤条件：表侧表示的超量·连接怪兽
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_XYZ+TYPE_LINK)
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽中存在超量·连接怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- ②效果的目标检查：确认自己主要怪兽区有可用空格且这张卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：若这张卡仍与当前连锁关联，则将其特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的「狱神」连接怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
-- ③效果作为起动效果的发动条件：这张卡当前未被赋予二速化能力
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定这张卡当前不能作为诱发即时效果发动
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
end
-- ③效果作为诱发即时效果的发动条件：这张卡被赋予二速化能力且自己场上存在「狱神」连接怪兽
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定这张卡可以作为诱发即时效果发动
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,37279096)
		-- 且自己场上存在至少1只「狱神」连接怪兽
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 除外对象过滤条件：可以除外的魔法·陷阱卡
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ③效果的目标处理：以最多有自己场上「狱神」连接怪兽数量的双方场上魔法·陷阱卡为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计自己场上「狱神」连接怪兽的数量作为可选对象的上限
	local ct=Duel.GetMatchingGroupCount(s.confilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.rmfilter(chkc) end
	-- 检查自己场上存在「狱神」连接怪兽且场上存在至少1张可作为对象的魔法·陷阱卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1至ct张双方场上的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：将对象卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果的处理：将仍与连锁关联且在场上的对象卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁关联且仍在场上的对象卡
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if tg:GetCount()>0 then
		-- 将那些卡以表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
