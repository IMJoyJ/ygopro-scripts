--毘龍之謙
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡·卡组把1只「虎菱之玄」在对方场上守备表示特殊召唤。
-- ②：这张卡用「虎菱之玄」的效果特殊召唤的场合发动。对方抽2张。那之后，对方选1张手卡丢弃。
-- ③：自己·对方的战斗阶段结束时发动。场上的这张卡回到手卡。
local s,id,o=GetID()
-- 注册三个效果：③战斗阶段结束时回到手卡、①主要阶段特殊召唤、②用虎菱之玄特殊召唤时发动的效果
function s.initial_effect(c)
	-- ③自己·对方的战斗阶段结束时发动。场上的这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①自己主要阶段才能发动。从手卡·卡组把1只「虎菱之玄」在对方场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤「虎菱之玄」"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②这张卡用「虎菱之玄」的效果特殊召唤的场合发动。对方抽2张。那之后，对方选1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"抽卡&丢弃"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 效果处理时设置操作信息，将自身送回手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将自身送回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理时执行将自身送回手卡的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送回手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 筛选可以特殊召唤的「虎菱之玄」卡片
function s.spfilter(c,e,tp)
	return c:IsCode(52126602) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理时判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组是否存在「虎菱之玄」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理时执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一张「虎菱之玄」进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 特殊召唤选中的「虎菱之玄」到对方场上
		Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断是否由「虎菱之玄」特殊召唤而来
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(52126602)>0
end
-- 效果处理时设置操作信息，设置对方抽2张和丢弃1张手牌
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方丢弃1张手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	-- 设置对方抽2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
end
-- 效果处理时执行对方抽2张并丢弃1张手牌的操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方是否成功抽2张卡
	if Duel.Draw(1-tp,2,REASON_EFFECT)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示对方选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 对方丢弃1张手牌
		Duel.DiscardHand(1-tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
