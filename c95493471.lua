--真超量機神王ブラスター・マグナ
-- 效果：
-- 包含「超级量子」怪兽的效果怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：连接召唤的这张卡不会被对方的效果破坏。
-- ②：每次有同名卡不在自己场上存在的「超级量子」超量怪兽从额外卡组往这张卡所连接区特殊召唤发动。自己从卡组抽1张。
-- ③：这张卡所连接区的超量怪兽被战斗或者对方的效果破坏的场合才能发动。原本属性和那只超量怪兽相同的1只「超级量子」怪兽从卡组特殊召唤。
function c95493471.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上的效果怪兽作为素材，且必须包含「超级量子」怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c95493471.lcheck)
	c:EnableReviveLimit()
	-- ①：连接召唤的这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(c95493471.indcon)
	-- 设置不会被破坏的效果来源为对方的效果
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：每次有同名卡不在自己场上存在的「超级量子」超量怪兽从额外卡组往这张卡所连接区特殊召唤发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95493471,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c95493471.drcon)
	e2:SetTarget(c95493471.drtg)
	e2:SetOperation(c95493471.drop)
	c:RegisterEffect(e2)
	-- ③：这张卡所连接区的超量怪兽被战斗或者对方的效果破坏的场合才能发动。原本属性和那只超量怪兽相同的1只「超级量子」怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95493471,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,95493471)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c95493471.spcon)
	e3:SetTarget(c95493471.sptg)
	e3:SetOperation(c95493471.spop)
	c:RegisterEffect(e3)
end
-- 连接召唤素材的额外检查：素材中必须包含至少1只「超级量子」怪兽
function c95493471.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xdc)
end
-- 效果①的启用条件：这张卡必须是连接召唤状态
function c95493471.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤特殊召唤的怪兽：属于「超级量子」的超量怪兽、从额外卡组特殊召唤、在当前卡的连接区，且自己场上不存在同名卡
function c95493471.cfilter(c,lg,tp)
	return c:IsSetCard(0xdc) and c:IsType(TYPE_XYZ) and c:IsSummonLocation(LOCATION_EXTRA) and lg:IsContains(c)
		-- 检查自己场上（除当前特殊召唤的怪兽外）不存在与该怪兽同名的卡
		and not Duel.IsExistingMatchingCard(c95493471.drfilter,tp,LOCATION_MZONE,0,1,c,c:GetCode())
end
-- 过滤自己场上表侧表示且卡名与指定卡名相同的怪兽
function c95493471.drfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 效果②的发动条件：检查特殊召唤的怪兽中是否存在满足条件的「超级量子」超量怪兽
function c95493471.drcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c95493471.cfilter,1,nil,lg,tp)
end
-- 效果②的靶向与操作信息设置：确定抽卡玩家为自己，抽卡数量为1张
function c95493471.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的靶向玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的靶向参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理：获取靶向玩家和参数，执行抽卡
function c95493471.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的靶向玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤被破坏的怪兽：原本在连接区、是超量怪兽，且被战斗破坏或被对方的效果破坏
function c95493471.cfilter2(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0 and c:IsType(TYPE_XYZ)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果③的发动条件：检查是否有连接区的超量怪兽被破坏，并记录这些被破坏怪兽的原本属性
function c95493471.spcon(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone()
	local g=eg:Filter(c95493471.cfilter2,nil,tp,zone)
	local attr=0
	-- 遍历所有满足条件的被破坏怪兽
	for tc in aux.Next(g) do
		attr=attr|tc:GetOriginalAttribute()
	end
	e:SetLabel(attr)
	return #g>0
end
-- 过滤卡组中可以特殊召唤的「超级量子」怪兽，且其原本属性与被破坏的超量怪兽相同
function c95493471.spfilter(c,e,tp,attr)
	return c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetOriginalAttribute()&attr>0
end
-- 效果③的发动准备：检查自己场上是否有空位，以及卡组中是否存在可特殊召唤的对应属性「超级量子」怪兽
function c95493471.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足属性条件的「超级量子」怪兽
		and Duel.IsExistingMatchingCard(c95493471.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组选择1只满足属性条件的「超级量子」怪兽特殊召唤到场上
function c95493471.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足属性条件的「超级量子」怪兽
	local g=Duel.SelectMatchingCard(tp,c95493471.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
