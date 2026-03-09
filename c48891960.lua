--ドラグニティナイト－アスカロン
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己墓地把1只「龙骑兵团」怪兽除外，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从额外卡组把1只攻击力3000以下的「龙骑兵团」同调怪兽当作同调召唤作特殊召唤。
function c48891960.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整（属于龙骑兵团）和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：从自己墓地把1只「龙骑兵团」怪兽除外，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48891960,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c48891960.rmcost)
	e1:SetTarget(c48891960.rmtg)
	e1:SetOperation(c48891960.rmop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从额外卡组把1只攻击力3000以下的「龙骑兵团」同调怪兽当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48891960,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48891960)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c48891960.spcon)
	e2:SetTarget(c48891960.sptg)
	e2:SetOperation(c48891960.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的卡片：属于龙骑兵团、是怪兽、可以作为除外的代价
function c48891960.cfilter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果处理时检查是否满足条件并选择一张墓地中的龙骑兵团怪兽除外作为代价
function c48891960.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48891960.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡作为除外的代价
	local g=Duel.SelectMatchingCard(tp,c48891960.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以正面表示形式除外作为效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标选择函数，用于选择对方场上的怪兽进行除外
function c48891960.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否满足条件：对方场上是否存在至少1张可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要除外1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果的执行函数，将目标怪兽除外
function c48891960.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示形式除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤满足条件的卡片：属于龙骑兵团、攻击力不超过3000、是同调怪兽、可以特殊召唤且有召唤空间
function c48891960.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsAttackBelow(3000) and c:IsType(TYPE_SYNCHRO)
		-- 检查是否可以特殊召唤该卡并确保场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判断效果发动条件，确认此卡被对方破坏且为同调召唤
function c48891960.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置特殊召唤的检索函数，检查额外卡组是否存在满足条件的龙骑兵团同调怪兽
function c48891960.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足必须成为素材的条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在至少1张满足spfilter条件的卡
		and Duel.IsExistingMatchingCard(c48891960.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的执行函数，从额外卡组选择并特殊召唤符合条件的龙骑兵团同调怪兽
function c48891960.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检测是否满足必须成为素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只满足条件的龙骑兵团同调怪兽
	local tc=Duel.SelectMatchingCard(tp,c48891960.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的卡以同调召唤方式特殊召唤到场上
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
