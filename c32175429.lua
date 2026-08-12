--ヒロイック・コール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地选1只战士族怪兽特殊召唤。这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽不能攻击，效果无效化。
-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升自己场上的「英豪」卡以及作为超量素材中的「英豪」卡数量×500。
local s,id,o=GetID()
-- 注册两个效果：①特殊召唤效果和②攻击力上升效果
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地选1只战士族怪兽特殊召唤。这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升自己场上的「英豪」卡以及作为超量素材中的「英豪」卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.atkcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：满足战士族且可以特殊召唤
function s.filter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件：场上存在空位且手牌或墓地存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果的发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足①效果的发动条件：手牌或墓地存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ①效果的处理函数：选择并特殊召唤1只满足条件的怪兽，若非英豪怪兽则使其不能攻击、效果无效化
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足①效果的处理条件：场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	-- 判断是否满足①效果的处理条件：选择的怪兽存在且为非英豪怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and not tc:IsSetCard(0x6f) then
		local c=e:GetHandler()
		-- 使该怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使该怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使该怪兽不能攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：自己基本分≤500
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己基本分≤500
	return Duel.GetLP(tp)<=500
end
-- 过滤条件：场上或叠放的英豪怪兽
function s.afilter(c)
	return c:IsSetCard(0x6f) and c:IsFaceup()
end
-- ②效果的目标选择函数：选择自己场上1只表侧表示怪兽，且场上有英豪怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 计算自己场上英豪怪兽数量
	local ct1=Duel.GetMatchingGroupCount(s.afilter,tp,LOCATION_ONFIELD,0,nil)
	-- 计算自己叠放区英豪怪兽数量
	local ct2=Duel.GetOverlayGroup(tp,1,0):FilterCount(Card.IsSetCard,nil,0x6f)
	-- 判断是否满足②效果的发动条件：场上存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and ct1+ct2>0 end
	-- 提示玩家选择要提升攻击力的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理函数：使目标怪兽攻击力上升自己场上的英豪怪兽数量×500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 计算自己场上英豪怪兽数量
		local ct1=Duel.GetMatchingGroupCount(s.afilter,tp,LOCATION_ONFIELD,0,nil)
		-- 计算自己叠放区英豪怪兽数量
		local ct2=Duel.GetOverlayGroup(tp,1,0):FilterCount(Card.IsSetCard,nil,0x6f)
		-- 使目标怪兽攻击力上升自己场上的英豪怪兽数量×500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue((ct1+ct2)*500)
		tc:RegisterEffect(e1)
	end
end
