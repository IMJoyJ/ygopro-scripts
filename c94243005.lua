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
	-- ②：1回合1次，把自己场上的混沌指示物4个以上去除，以持有和去除数量相同等级的除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
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
	-- 注册离场前保存指示物数量的持续效果
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
c94243005.mentioned_counter={
	[0x13]=true,
}
-- 放置指示物过滤条件：表侧表示被除外且原位置非魔法陷阱区的非衍生物怪兽
function c94243005.ctfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(0x80+LOCATION_SZONE) and not c:IsType(TYPE_TOKEN)
end
-- ①效果处理：根据表侧表示被除外的怪兽数量为此卡放置混沌指示物
function c94243005.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c94243005.ctfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x13,ct)
	end
end
-- 特召目标过滤：除外区等级4以上表侧表示怪兽，且场上有足够指示物可去除并能特殊召唤
function c94243005.spfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 检查卡片等级是否大于3、表侧表示、可去除对应等级数量的指示物且能被特殊召唤
	return lv>3 and c:IsFaceup() and Duel.IsCanRemoveCounter(tp,1,0,0x13,lv,REASON_COST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果目标选择：选择除外区符合等级要求的怪兽，去除对应数量的混沌指示物作为Cost
function c94243005.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c94243005.spfilter(chkc,e,tp) end
	-- 检查自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方除外区是否存在满足等级和Cost条件的表侧表示怪兽
		and Duel.IsExistingTarget(c94243005.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的怪兽作为特召对象
	local g=Duel.SelectTarget(tp,c94243005.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 从场上去除与目标怪兽等级相同数量的混沌指示物
	Duel.RemoveCounter(tp,1,0,0x13,g:GetFirst():GetLevel(),REASON_COST)
	-- 设置连锁操作信息：特殊召唤选择的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将选择的目标怪兽在自己场上表侧表示特殊召唤
function c94243005.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特召的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 离场前处理：记录此卡离场前拥有的混沌指示物数量
function c94243005.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x13)
	e:SetLabel(ct)
end
-- ③效果发动条件检查：卡在自己场上被对方效果送墓，且离场前有混沌指示物
function c94243005.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and ct>0 and rp==1-tp and bit.band(r,REASON_EFFECT)~=0
end
-- 检索卡片过滤条件：等级在记载指示物数量以下的光·暗属性怪兽
function c94243005.thfilter(c,lv)
	return c:IsLevelBelow(lv) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ③效果发动准备：设置从卡组检索怪兽的操作信息
function c94243005.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在等级不高于指示物数量的光·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94243005.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组把1只满足等级要求的光·暗属性怪兽加入手牌
function c94243005.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的光·暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c94243005.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()~=0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
