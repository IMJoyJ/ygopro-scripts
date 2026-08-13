--HSRマッハゴー・イータ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。场上的全部表侧表示怪兽的等级直到回合结束时上升1星。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在，自己场上有「疾行机人」调整存在的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c21516908.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（无额外限制）＋1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把这张卡解放才能发动。场上的全部表侧表示怪兽的等级直到回合结束时上升1星。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21516908,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c21516908.lvcost)
	e1:SetTarget(c21516908.lvtg)
	e1:SetOperation(c21516908.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「疾行机人」调整存在的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21516908,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21516908)
	e2:SetCondition(c21516908.spcon)
	e2:SetTarget(c21516908.sptg)
	e2:SetOperation(c21516908.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价：将这张卡自身解放作为发动代价。
function c21516908.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放这张卡作为代价来处理（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上的表侧表示怪兽，且当前等级大于0。
function c21516908.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- ①效果发动时点检查：确认场上是否存在除自身以外的满足过滤条件的表侧表示怪兽，以判断是否可以发动。
function c21516908.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若场上存在至少1只满足条件的表侧表示怪兽（自身除外），则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21516908.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
-- ①效果处理：取得场上全部满足条件的表侧表示怪兽，逐一将它们的等级上升1星，持续到回合结束。
function c21516908.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得场上所有表侧表示且等级大于0的怪兽的集合（此处无需除外自身，因为发动时已解放）。
	local g=Duel.GetMatchingGroup(c21516908.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部表侧表示怪兽的等级直到回合结束时上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤条件：表侧表示且为「疾行机人」系列调整怪兽。
function c21516908.hsfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER)
end
-- ②效果发动条件：自己场上存在1只表侧表示的「疾行机人」调整怪兽。
function c21516908.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的「疾行机人」调整怪兽。
	return Duel.IsExistingMatchingCard(c21516908.hsfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果发动目标判定：自己主要怪兽区有空位，且这张墓地的卡可以被特殊召唤。
function c21516908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上有至少1个可用怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁要进行的特殊召唤信息（对象为自身、数量1）注册到当前连锁，供相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤时的限制条件：只要不是风属性怪兽，就不能进行特殊召唤。
function c21516908.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- ②效果处理：将墓地中的这张卡特殊召唤到自己场上，并给己方附加只能特殊召唤风属性怪兽的自肃效果直到回合结束。
function c21516908.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21516908.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非风属性怪兽的自肃效果注册给当前玩家tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
