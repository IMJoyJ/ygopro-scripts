--虎菱之玄
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡·卡组把1只「毘龙之谦」在对方场上守备表示特殊召唤。
-- ②：这张卡用「毘龙之谦」的效果特殊召唤的场合发动。选自己1张手卡丢弃。
-- ③：自己·对方的战斗阶段结束时发动。场上的这张卡回到手卡。
local s,id,o=GetID()
-- 初始化效果，注册三个效果：③战斗阶段结束时回到手卡、①主要阶段特殊召唤毘龙之谦、②被毘龙之谦特殊召唤时丢弃手卡
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
	-- ①自己主要阶段才能发动。从手卡·卡组把1只「毘龙之谦」在对方场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤「毘龙之谦」"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②这张卡用「毘龙之谦」的效果特殊召唤的场合发动。选自己1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"丢弃手卡"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 效果作用：设置回到手卡效果的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将自身送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果作用：执行回到手卡效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤函数：判断是否为毘龙之谦且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(25131968) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：设置特殊召唤毘龙之谦的效果目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在毘龙之谦
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤一张毘龙之谦
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果作用：执行特殊召唤毘龙之谦
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只毘龙之谦进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的毘龙之谦特殊召唤到对方场上
		Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 效果作用：判断是否被毘龙之谦特殊召唤
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(25131968)>0
end
-- 效果作用：设置丢弃手卡的效果目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为丢弃一张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果作用：执行丢弃手卡效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 丢弃一张手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
end
