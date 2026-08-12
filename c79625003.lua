--SNo.37 スパイダー・シャーク
-- 效果：
-- 水属性5星怪兽×3
-- 这张卡也能在自己场上的「No.37 希望织龙 蜘蛛鲨」上面重叠来超量召唤。
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽直到下次的对方准备阶段除外，对方场上有怪兽存在的场合，那些攻击力直到回合结束时下降1000。
-- ②：超量召唤的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册超量召唤手续、①效果（起动效果：除外对方怪兽并降攻）、②效果的破坏送墓标记效果（不入连锁）以及结束阶段的特殊召唤效果（诱发效果）
function s.initial_effect(c)
	-- 将「No.37 希望织龙 蜘蛛鲨」加入到该卡的关联卡片密码列表中
	aux.AddCodeList(c,37279508)
	aux.AddXyzProcedure(c,s.mfilter,5,3,s.ovfilter,aux.Stringid(id,0))  --"是否在「No.37 希望织龙 蜘蛛鲨」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽直到下次的对方准备阶段除外，对方场上有怪兽存在的场合，那些攻击力直到回合结束时下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡被破坏送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ②：超量召唤的这张卡被破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的「No.」编号为37
aux.xyz_number[id]=37
-- 超量召唤素材的过滤条件：水属性怪兽
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 重叠超量召唤的素材过滤条件：自己场上表侧表示的「No.37 希望织龙 蜘蛛鲨」
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(37279508)
end
-- ①效果的Cost：取除这张卡的1个超量素材
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的Target：确认对方场上是否存在可除外的怪兽，并选择其作为效果的对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在至少1只可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择对方场上1只可以被除外的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息，表示该效果包含除外1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的Operation：将作为对象的怪兽暂时除外，并注册在下次对方准备阶段返回场上的效果；若对方场上仍有怪兽存在，则使那些怪兽的攻击力直到回合结束时下降1000
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果关联且为怪兽，并将其以效果原因暂时除外
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,0,1)
		-- 那只怪兽直到下次的对方准备阶段除外，对方场上有怪兽存在的场合
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
		-- 注册用于在下次对方准备阶段将除外怪兽返回场上的全局时点效果
		Duel.RegisterEffect(e1,tp)
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		-- 遍历对方场上所有表侧表示的怪兽
		for fc in aux.Next(g) do
			-- 那些攻击力直到回合结束时下降1000。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(-1000)
			fc:RegisterEffect(e2)
		end
	end
end
-- 暂时除外怪兽返回场上效果的发动条件：当前是对方的回合，且该怪兽带有对应的标记
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合），且被除外的怪兽仍持有该效果注册的标记
	return Duel.GetTurnPlayer()~=tp and e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 暂时除外怪兽返回场上效果的具体处理
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 检查这张卡是否是超量召唤的卡被破坏送去墓地，并在结束阶段前为自身注册一个标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②效果的Condition：检查这张卡是否在被破坏送去墓地的回合，即自身是否带有对应的标记
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- ②效果的Target：检查自身是否可以特殊召唤，以及自己场上是否有空位，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以特殊召唤，且自己场上的怪兽区域有空位
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁处理的操作信息，表示该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的Operation：将墓地的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联，且不受「王家长眠之谷」的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
