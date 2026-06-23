--ギミック・パペット－テラー・ベビー
-- 效果：
-- ①：这张卡召唤成功时，以「机关傀儡-恐怖婴儿」以外的自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：把墓地的这张卡除外才能发动。这个回合，对方不能对应自己的「机关傀儡」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c43598843.initial_effect(c)
	-- ①：这张卡召唤成功时，以「机关傀儡-恐怖婴儿」以外的自己墓地1只「机关傀儡」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43598843,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c43598843.sptg)
	e1:SetOperation(c43598843.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，对方不能对应自己的「机关傀儡」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43598843,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c43598843.target)
	e2:SetOperation(c43598843.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤的过滤条件：满足机关傀儡卡组、不是此卡本身、可以特殊召唤
function c43598843.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and not c:IsCode(43598843) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 选择特殊召唤目标的处理：判断是否满足特殊召唤条件
function c43598843.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43598843.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否有满足条件的怪兽
		and Duel.IsExistingTarget(c43598843.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c43598843.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作：将选中的怪兽以守备表示特殊召唤
function c43598843.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断是否已发动过此效果
function c43598843.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已发动过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,43598843)==0 end
end
-- 注册连锁限制效果：使对方不能对应己方机关傀儡怪兽的效果发动魔法/陷阱/怪兽效果
function c43598843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册连锁限制效果：使对方不能对应己方机关傀儡怪兽的效果发动魔法/陷阱/怪兽效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c43598843.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将连锁限制效果注册到场上
	Duel.RegisterEffect(e1,tp)
	-- 注册标识效果：标记此效果已发动
	Duel.RegisterFlagEffect(tp,43598843,RESET_PHASE+PHASE_END,0,1)
end
-- 连锁限制效果的处理函数：当对方发动机关傀儡怪兽的效果时，禁止其发动
function c43598843.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x1083) and ep==tp then
		-- 设置连锁限制：禁止对方发动魔法/陷阱/怪兽效果
		Duel.SetChainLimit(c43598843.chainlm)
	end
end
-- 连锁限制条件函数：只有自己发动的效果才能被限制
function c43598843.chainlm(e,rp,tp)
	return tp==rp
end
