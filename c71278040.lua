--パラレルエクシード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己把怪兽连接召唤的场合才能发动。这张卡在作为那只连接怪兽所连接区的自己场上特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「并行超限龙」特殊召唤。
-- ③：「并行超限龙」的效果特殊召唤的这张卡的等级变成4星，原本的攻击力·守备力变成一半。
function c71278040.initial_effect(c)
	-- ①：这张卡在手卡存在，自己把怪兽连接召唤的场合才能发动。这张卡在作为那只连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71278040,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71278040)
	e1:SetCondition(c71278040.spcon1)
	e1:SetTarget(c71278040.sptg1)
	e1:SetOperation(c71278040.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「并行超限龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71278040,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,71278041)
	e2:SetTarget(c71278040.sptg2)
	e2:SetOperation(c71278040.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：「并行超限龙」的效果特殊召唤的这张卡的等级变成4星，原本的攻击力·守备力变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c71278040.lvcon)
	e4:SetOperation(c71278040.lvop)
	c:RegisterEffect(e4)
end
-- 检查特殊召唤此卡的效果是否为「并行超限龙」的效果
function c71278040.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该特殊召唤事件的连锁效果的卡片密码
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return re and (code1==71278040 or code2==71278040)
end
-- 将此卡的等级变成4星，原本的攻击力·守备力变成一半
function c71278040.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local batk=c:GetBaseAttack()
	local bdef=c:GetBaseDefense()
	-- 等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(math.ceil(batk/2))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	e3:SetValue(math.ceil(bdef/2))
	c:RegisterEffect(e3)
end
-- 过滤出自己场上表侧表示的连接召唤成功的怪兽
function c71278040.cfilter1(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 检查是否有自己连接召唤怪兽的事件发生
function c71278040.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c71278040.cfilter1,1,nil,tp)
end
-- 检查手牌中的此卡是否能特殊召唤到该连接怪兽所连接的区域，并设置操作信息
function c71278040.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if eg:GetCount()~=1 then return false end
	local tc=eg:GetFirst()
	local zone=tc:GetLinkedZone(tp)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 将该连接召唤的怪兽设为效果处理的对象
	Duel.SetTargetCard(tc)
	-- 设置连锁操作信息为特殊召唤手牌中的此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 将此卡特殊召唤到该连接怪兽所连接的自己场上的区域
function c71278040.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的连接怪兽
	local tc=Duel.GetFirstTarget()
	local zone=tc:GetLinkedZone(tp)
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and zone&0x1f~=0 then
		-- 将此卡以表侧表示特殊召唤到指定的连接区
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 过滤卡组中可以特殊召唤的「并行超限龙」
function c71278040.cfilter2(c,e,tp)
	return c:IsCode(71278040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查自己场上是否有空位且卡组中是否存在可以特殊召唤的「并行超限龙」
function c71278040.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「并行超限龙」
		and Duel.IsExistingMatchingCard(c71278040.cfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组选择1只「并行超限龙」特殊召唤
function c71278040.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「并行超限龙」
	local g=Duel.SelectMatchingCard(tp,c71278040.cfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「并行超限龙」表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
