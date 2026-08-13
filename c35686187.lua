--断頭台の惨劇
-- 效果：
-- 对方场上表侧攻击表示存在的怪兽的表示形式变更为表侧守备表示时才能发动。对方场上守备表示存在的怪兽全部破坏。
function c35686187.initial_effect(c)
	-- 对方场上表侧攻击表示存在的怪兽的表示形式变更为表侧守备表示时才能发动。对方场上守备表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c35686187.condition)
	e1:SetTarget(c35686187.target)
	e1:SetOperation(c35686187.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足触发条件的怪兽：该怪兽的控制者为对方，且在表示形式变更前是表侧攻击表示，变更后是表侧守备表示。
function c35686187.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousPosition(POS_FACEUP_ATTACK) and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 发动条件判断：此次表示形式变更事件中，至少存在1只满足上述条件的对方怪兽，即发生了对方怪兽从表侧攻击表示变为表侧守备表示的情况。
function c35686187.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35686187.cfilter,1,nil,1-tp)
end
-- 筛选出场上所有守备表示怪兽，作为本效果破坏的对象条件。
function c35686187.filter(c)
	return c:IsDefensePos()
end
-- 发动时目标处理：确认对方场上存在守备表示怪兽后，获取对方场上全部守备表示怪兽，并设置破坏的操作信息。
function c35686187.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：效果发动时必须存在至少1只对方场上的守备表示怪兽才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35686187.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取当前对方场上所有守备表示怪兽的集合，用于设置操作信息。
	local g=Duel.GetMatchingGroup(c35686187.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置本连锁的操作信息，声明将破坏这些守备表示怪兽，破坏数量为当前集合的卡片数量，供连锁和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：重新获取当前对方场上所有守备表示怪兽，若存在则将其全部破坏。
function c35686187.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上所有守备表示怪兽的集合，以当前场上状态为准。
	local g=Duel.GetMatchingGroup(c35686187.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因将这些守备表示怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
