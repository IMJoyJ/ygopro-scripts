--ガガガガマジシャン
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以「我我我我魔术师」以外的自己墓地1只超量怪兽为对象才能发动。那只怪兽效果无效特殊召唤。
-- ②：有这张卡在作为超量素材中的「未来皇 霍普」超量怪兽得到以下效果。
-- ●把这张卡2个超量素材取除，以自己场上1只超量怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成4000，效果无效化。
function c86331741.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	-- ①：把这张卡1个超量素材取除，以「我我我我魔术师」以外的自己墓地1只超量怪兽为对象才能发动。那只怪兽效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86331741,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,86331741)
	e1:SetCost(c86331741.spcost)
	e1:SetTarget(c86331741.sptg)
	e1:SetOperation(c86331741.spop)
	c:RegisterEffect(e1)
	-- ②：有这张卡在作为超量素材中的「未来皇 霍普」超量怪兽得到以下效果。●把这张卡2个超量素材取除，以自己场上1只超量怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成4000，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86331741,1))  --"攻击力变成4000（我我我我魔术师）"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c86331741.atkcon)
	e2:SetCost(c86331741.atkcost)
	e2:SetTarget(c86331741.atktg)
	e2:SetOperation(c86331741.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的COST：把这张卡1个超量素材取除
function c86331741.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的特殊召唤目标筛选：自己墓地「我我我我魔术师」以外的超量怪兽
function c86331741.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and not c:IsCode(86331741) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的靶向/发动条件判定（Target）
function c86331741.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86331741.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足特殊召唤条件的合法目标
		and Duel.IsExistingTarget(c86331741.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只满足条件的超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86331741.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：包含特殊召唤分类，数量为1，目标为选择的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（Operation）：将目标怪兽效果无效并特殊召唤
function c86331741.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，则尝试将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 那只怪兽效果无效特殊召唤。②：有这张卡在作为超量素材中的「未来皇 霍普」超量怪兽得到以下效果。●把这张卡2个超量素材取除，以自己场上1只超量怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成4000，效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 赋予效果的发动条件：作为超量素材的怪兽是「未来皇 霍普」超量怪兽
function c86331741.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x207f) and c:IsType(TYPE_XYZ)
end
-- 赋予效果的COST：把这张卡2个超量素材取除
function c86331741.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 赋予效果的目标筛选：自己场上表侧表示的超量怪兽，且攻击力不为4000或效果未被无效
function c86331741.atkfilter(c)
	-- 筛选场上表侧表示的超量怪兽，且其攻击力不为4000或其效果可以被无效
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and (not c:IsAttack(4000) or aux.NegateMonsterFilter(c))
end
-- 赋予效果的靶向/发动条件判定（Target）
function c86331741.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86331741.atkfilter(chkc) end
	-- 判定自己场上是否存在满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c86331741.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只满足条件的超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86331741.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 赋予效果的效果处理（Operation）：直到回合结束时，目标怪兽的攻击力变成4000，效果无效化
function c86331741.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到回合结束时，那只怪兽的攻击力变成4000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(4000)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
