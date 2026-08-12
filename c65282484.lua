--ダーク・ボルテニス
-- 效果：
-- 自己对反击陷阱的发动成功的场合，可以把自己场上存在的1只暗属性怪兽解放，从手卡把这张卡特殊召唤。这个效果特殊召唤成功时，场上存在的1张卡破坏。
function c65282484.initial_effect(c)
	-- 自己对反击陷阱的发动成功的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(c65282484.chop1)
	c:RegisterEffect(e1)
	-- 自己对反击陷阱的发动成功的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c65282484.chop2)
	c:RegisterEffect(e2)
	-- 自己对反击陷阱的发动成功的场合，可以把自己场上存在的1只暗属性怪兽解放，从手卡把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65282484,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c65282484.spcon)
	e3:SetCost(c65282484.spcost)
	e3:SetTarget(c65282484.sptg)
	e3:SetOperation(c65282484.spop)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
	-- 这个效果特殊召唤成功时，场上存在的1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65282484,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c65282484.descon)
	e4:SetTarget(c65282484.destg)
	e4:SetOperation(c65282484.desop)
	c:RegisterEffect(e4)
end
-- 在有连锁发动时，将反击陷阱发动成功的标记重置为0
function c65282484.chop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
-- 在连锁处理完毕时，若自己成功发动了反击陷阱，则将标记设为1
function c65282484.chop2(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) then return end
	e:GetLabelObject():SetLabel(1)
end
-- 检查反击陷阱发动成功的标记是否为1
function c65282484.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
-- 过滤自己场上可解放的暗属性怪兽，并考虑怪兽区域空位限制
function c65282484.cfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 解放自己场上1只暗属性怪兽的Cost处理函数
function c65282484.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动检查时，确认玩家场上是否有可解放的暗属性怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c65282484.cfilter,1,nil,ft,tp) end
	-- 让玩家选择1只满足条件的暗属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c65282484.cfilter,1,1,nil,ft,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的Target处理函数，检查自身是否能特殊召唤并设置操作信息
function c65282484.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation处理函数，执行特殊召唤
function c65282484.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以自身效果的特殊召唤方式表侧表示特殊召唤到场上
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查这张卡是否是通过自身效果特殊召唤成功的
function c65282484.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 破坏效果的Target处理函数，选择场上1张卡作为对象并设置操作信息
function c65282484.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 向玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上存在的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏的操作信息，包含被选择的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的Operation处理函数，执行破坏
function c65282484.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择为破坏对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
