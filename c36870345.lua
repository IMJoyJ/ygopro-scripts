--ドラグニティ－アキュリス
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只「龙骑兵团」怪兽特殊召唤，那之后，自己场上的表侧表示的这张卡当作装备卡使用给那只特殊召唤的怪兽装备。
-- ②：给怪兽装备的这张卡被送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。
function c36870345.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只「龙骑兵团」怪兽特殊召唤，那之后，自己场上的表侧表示的这张卡当作装备卡使用给那只特殊召唤的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36870345,0))  --"特殊召唤并装备"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c36870345.sptg)
	e1:SetOperation(c36870345.spop)
	c:RegisterEffect(e1)
	-- ②：给怪兽装备的这张卡被送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36870345,1))  --"场上的1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36870345.descon)
	e2:SetTarget(c36870345.destg)
	e2:SetOperation(c36870345.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的「龙骑兵团」怪兽（可以特殊召唤）
function c36870345.filter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断，检查是否满足特殊召唤和装备的条件
function c36870345.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的「龙骑兵团」怪兽
		and Duel.IsExistingMatchingCard(c36870345.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：准备将自身作为装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤和装备操作
function c36870345.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只「龙骑兵团」怪兽
	local g=Duel.SelectMatchingCard(tp,c36870345.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		-- 检查玩家场上是否有足够的魔法区域
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 尝试将自身装备给特殊召唤的怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置装备对象限制效果，确保该装备卡只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c36870345.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备对象限制函数，判断目标怪兽是否为装备对象
function c36870345.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 破坏效果的发动条件函数，判断该卡是否因装备而被送去墓地
function c36870345.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 破坏效果的目标选择函数，选择场上1张卡作为破坏对象
function c36870345.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：准备破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理函数，执行破坏操作
function c36870345.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
