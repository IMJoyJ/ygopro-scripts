--R.B. Last Stand
-- 效果：
-- 从自己的卡组·额外卡组·墓地把同名卡不在自己场上存在的1只「奏悦机组」怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
-- 自己场上的「奏悦机组」怪兽为对象的卡的效果由对方发动时：可以从自己墓地把这张卡除外；那个效果无效。
-- 「奏悦机组 背水一战」的效果1回合只能有1次使用其中任意1个。
local s,id,o=GetID()
-- 创建两个效果，第一个为发动效果，第二个为诱发效果
function s.initial_effect(c)
	-- 发动效果：从自己的卡组·额外卡组·墓地把同名卡不在自己场上存在的1只「奏悦机组」怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 诱发效果：自己场上的「奏悦机组」怪兽为对象的卡的效果由对方发动时，可以从自己墓地把这张卡除外；那个效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 特殊召唤过滤条件：满足「奏悦机组」种族、可以特殊召唤、场上不存在同名卡、且满足位置和怪兽区空位条件
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 场上不存在同名卡
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		-- 在卡组或墓地且有怪兽区空位
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 在额外卡组且有额外卡组召唤空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 判断是否满足特殊召唤条件并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 发动效果处理：选择并特殊召唤符合条件的怪兽，并设置后续限制效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 特殊召唤选中的怪兽
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置发动后限制效果：直到回合结束时自己不是攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		-- 注册限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的目标过滤条件：只能从额外卡组特殊召唤非机械族或攻击力超过1500的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500)
end
-- 判断是否为己方场上「奏悦机组」怪兽
function s.cfilter(c,tp)
	return c:IsSetCard(0x1cf) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsFaceup()
end
-- 诱发效果的发动条件：对方发动的效果具有目标且目标包含己方场上「奏悦机组」怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁的目标卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then return false end
	local c=e:GetHandler()
	-- 判断连锁是否可无效
	return Duel.IsChainNegatable(ev)
		and g:IsExists(s.cfilter,1,nil,tp)
end
-- 设置无效效果的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
