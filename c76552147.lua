--D・D・D
-- 效果：
-- ①：以下其中任意种的怪兽在自己场上表侧表示存在的场合，以场上1张卡为对象才能发动。那张卡除外。
-- ●使用通常怪兽作仪式召唤的怪兽
-- ●通常怪兽为素材作融合·同调·超量·连接召唤的怪兽
function c76552147.initial_effect(c)
	-- ①：以下其中任意种的怪兽在自己场上表侧表示存在的场合，以场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c76552147.condition)
	e1:SetTarget(c76552147.target)
	e1:SetOperation(c76552147.activate)
	c:RegisterEffect(e1)
	if not c76552147.global_check then
		c76552147.global_check=true
		-- ●使用通常怪兽作仪式召唤的怪兽 ●通常怪兽为素材作融合·同调·超量·连接召唤的怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c76552147.valcheck)
		-- 在全局环境注册该素材检查效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查怪兽的召唤素材，若包含通常怪兽则给该怪兽注册特定的Flag标记
function c76552147.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then c:RegisterFlagEffect(76552147,RESET_EVENT+0x4fe0000,0,1) end
end
-- 过滤出场上表侧表示、且由通常怪兽作为素材进行仪式·融合·同调·超量·连接召唤的怪兽
function c76552147.cfilter(c)
	if c:IsFacedown() or c:GetFlagEffect(76552147)==0 then return false end
	for _,st in ipairs{SUMMON_TYPE_RITUAL,SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK} do
		if c:IsSummonType(st) then return true end
	end
	return false
end
-- 效果的发动条件：自己场上存在满足条件的怪兽
function c76552147.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c76552147.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果的发动阶段：选择场上1张卡作为除外对象
function c76552147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() and chkc~=c end
	-- 在发动时，检查场上是否存在除这张卡以外、可以被除外的卡作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 给发动效果的玩家发送提示信息，提示其选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择场上1张可以被除外的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置当前连锁的操作信息，表示该效果包含除外1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果的处理阶段：将作为对象的卡除外
function c76552147.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
