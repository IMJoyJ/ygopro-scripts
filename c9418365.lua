--武神－ヒルメ
-- 效果：
-- 这张卡不能通常召唤。把「武神-日孁」以外的自己墓地1只名字带有「武神」的怪兽从游戏中除外的场合可以特殊召唤。此外，这个方法特殊召唤的这张卡被对方破坏送去墓地的场合才能发动。自己丢弃1张手卡。那之后，对方选1张手卡丢弃。「武神-日孁」在自己场上只能有1只表侧表示存在。
function c9418365.initial_effect(c)
	c:SetUniqueOnField(1,0,9418365)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「武神-日孁」以外的自己墓地1只名字带有「武神」的怪兽从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9418365,0))  --"丢弃手卡"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(SUMMON_VALUE_SELF)
	e1:SetCondition(c9418365.spcon)
	e1:SetTarget(c9418365.sptg)
	e1:SetOperation(c9418365.spop)
	c:RegisterEffect(e1)
	-- 此外，这个方法特殊召唤的这张卡被对方破坏送去墓地的场合才能发动。自己丢弃1张手卡。那之后，对方选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9418365,1))
	e2:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c9418365.hdcon)
	e2:SetTarget(c9418365.hdtg)
	e2:SetOperation(c9418365.hdop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中「武神-日孁」以外的名字带有「武神」的怪兽，且该怪兽可以作为Cost被除外
function c9418365.spfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and not c:IsCode(9418365) and c:IsAbleToRemoveAsCost()
end
-- 检查自身特殊召唤的条件是否满足（场上有空位且墓地有符合条件的怪兽）
function c9418365.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c9418365.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤的准备阶段，获取墓地中符合条件的怪兽并让玩家选择1只，将其记录在效果对象中
function c9418365.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c9418365.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的执行阶段，将选中的怪兽除外以完成特殊召唤
function c9418365.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 检查发动条件：此卡必须是通过自身效果特殊召唤，被对方破坏并送去墓地，且之前在自己的怪兽区域
function c9418365.hdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 效果发动时的目标检查，确认双方手卡数量均大于0，并设置效果处理信息
function c9418365.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查对方手卡数量是否大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理：自己丢弃1张手卡，之后对方丢弃1张手卡
function c9418365.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 让自己选择并丢弃1张手卡，如果成功丢弃则继续处理
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 中断当前效果处理，使后续的对方丢弃手卡处理不与自己丢弃手卡视为同时处理（对应“那之后”）
		Duel.BreakEffect()
		-- 让对方选择并丢弃1张手卡
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
