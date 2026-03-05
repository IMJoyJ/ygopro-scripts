--回猫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
-- ②：反转过的这张卡在怪兽区域存在的状态，怪兽从手卡·卡组送去自己墓地的场合，以那之内的1只为对象才能发动。那只怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 创建效果：①效果和②效果的初始化设置
function s.initial_effect(c)
	-- ①：这张卡从手卡·卡组送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：反转过的这张卡在怪兽区域存在的状态，怪兽从手卡·卡组送去自己墓地的场合，以那之内的1只为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 翻转时记录flag，用于②效果的触发条件判断
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.flipop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：确认此卡是从手牌或卡组送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- 效果①的发动准备：判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置效果①的处理信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：将此卡特殊召唤到场上并确认其卡面
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 向对方确认此卡的卡面
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 过滤满足条件的墓地怪兽：从手牌或卡组送去墓地且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and c:IsCanBeEffectTarget(e)
end
-- 效果②的发动条件：此卡反转且场上存在满足条件的墓地怪兽
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetFlagEffect(id)>0 and eg:IsExists(s.spfilter,1,nil,e,tp)
end
-- 效果②的发动准备：选择目标怪兽并设置处理信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
	-- 设置效果②的目标怪兽
	Duel.SetTargetCard(g)
	-- 设置效果②的处理信息：将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：将目标怪兽特殊召唤到场上并确认其卡面
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否能被特殊召唤且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方确认目标怪兽的卡面
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 翻转时注册flag，用于②效果的触发条件判断
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
