--混沌空間
-- 效果：
-- ①：每次怪兽被表侧表示除外，每有1只给这张卡放置1个混沌指示物。
-- ②：1回合1次，把自己场上的混沌指示物4个以上取除，以持有和取除数量相同等级的除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
-- ③：场上的这张卡被对方的效果送去墓地时才能发动。把持有这张卡放置的混沌指示物数量以下的等级的1只光·暗属性的怪兽从卡组加入手卡。
function c94243005.initial_effect(c)
	c:EnableCounterPermit(0x13)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次怪兽被表侧表示除外，每有1只给这张卡放置1个混沌指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c94243005.ctop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己场上的混沌指示物4个以上取除，以持有和取除数量相同等级的除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetDescription(aux.Stringid(94243005,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c94243005.sptg)
	e3:SetOperation(c94243005.spop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被对方的效果送去墓地时才能发动。把持有这张卡放置的混沌指示物数量以下的等级的1只光·暗属性的怪兽从卡组加入手卡。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c94243005.regop)
	c:RegisterEffect(e0)
	-- ③：场上的这张卡被对方的效果送去墓地时才能发动。把持有这张卡放置的混沌指示物数量以下的等级的1只光·暗属性的怪兽从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetDescription(aux.Stringid(94243005,1))  --"检索"
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c94243005.thcon)
	e4:SetTarget(c94243005.thtg)
	e4:SetOperation(c94243005.thop)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
end
-- 过滤除外时需要放置指示物的怪兽：表侧表示的非衍生物怪兽，且不是从魔法与陷阱区域被除外
function c94243005.ctfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(0x80+LOCATION_SZONE) and not c:IsType(TYPE_TOKEN)
end
-- 计算本次被表侧表示除外的怪兽数量，并给这张卡放置相同数量的混沌指示物
function c94243005.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c94243005.ctfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x13,ct)
	end
end
-- 过滤可以作为特殊召唤对象的除外怪兽：等级在4以上、表侧表示、可以通过去除其等级数量的混沌指示物作为Cost、且可以被特殊召唤
function c94243005.spfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 判定怪兽等级是否在4以上、是否表侧表示、玩家是否能移除与该怪兽等级相同数量的混沌指示物作为Cost、以及该怪兽是否能特殊召唤
	return lv>3 and c:IsFaceup() and Duel.IsCanRemoveCounter(tp,1,0,0x13,lv,REASON_COST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target函数，用于检查发动条件、进行取对象判定以及在发动时声明操作
function c94243005.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c94243005.spfilter(chkc,e,tp) end
	-- 在效果发动准备阶段，检查己方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果发动准备阶段，检查除外区域是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c94243005.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 向发动效果的玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择除外区域的1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c94243005.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 作为发动Cost，从己方场上移除与对象怪兽等级相同数量的混沌指示物
	Duel.RemoveCounter(tp,1,0,0x13,g:GetFirst():GetLevel(),REASON_COST)
	-- 设置效果处理信息，表示此效果包含将选中的1只怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的Operation函数，将选中的对象怪兽特殊召唤到己方场上
function c94243005.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 在卡片离开场上时，记录其当前放置的混沌指示物数量
function c94243005.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x13)
	e:SetLabel(ct)
end
-- 检查检索效果的发动条件：此卡之前在己方场上存在，因对方的效果被送去墓地，且离场前放置有至少1个混沌指示物
function c94243005.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and ct>0 and rp==1-tp and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤可以检索的怪兽：等级在记录的指示物数量以下、光属性或暗属性、且可以加入手卡
function c94243005.thfilter(c,lv)
	return c:IsLevelBelow(lv) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 检索效果的Target函数，检查卡组中是否存在满足条件的怪兽，并设置操作信息
function c94243005.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查己方卡组中是否存在至少1只等级在记录的指示物数量以下的光·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94243005.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置效果处理信息，表示此效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation函数，从卡组选择1只满足条件的怪兽加入手卡，并向对方展示
function c94243005.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c94243005.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()~=0 then
		-- 将选择的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
