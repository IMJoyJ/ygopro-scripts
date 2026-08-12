--星遺物を巡る戦い
-- 效果：
-- ①：把自己场上1只表侧表示怪兽直到结束阶段除外，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力下降因为这张卡发动而除外的怪兽的各自原本数值。
function c93236220.initial_effect(c)
	-- ①：把自己场上1只表侧表示怪兽直到结束阶段除外，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力下降因为这张卡发动而除外的怪兽的各自原本数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤中伤害计算前（或非伤害步骤）
	e1:SetCondition(aux.dscon)
	e1:SetCost(c93236220.cost)
	e1:SetTarget(c93236220.target)
	e1:SetOperation(c93236220.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、且原本攻击力或原本守备力大于0、且可以作为代价除外的怪兽
function c93236220.cfilter(c)
	return c:IsFaceup() and (c:GetTextAttack()>0 or c:GetTextDefense()>0) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价：选择自己场上1只表侧表示怪兽暂时除外，并记录其原本攻击力和守备力，同时注册在结束阶段将其返回场上的效果
function c93236220.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93236220.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1只满足过滤条件的怪兽
	local rc=Duel.SelectMatchingCard(tp,c93236220.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	e:SetLabel(rc:GetTextAttack(),rc:GetTextDefense())
	-- 将选择的怪兽作为代价暂时除外，若除外成功则执行后续处理
	if Duel.Remove(rc,0,REASON_COST+REASON_TEMPORARY)~=0 then
		-- ①：把自己场上1只表侧表示怪兽直到结束阶段除外，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力下降因为这张卡发动而除外的怪兽的各自原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetOperation(c93236220.retop)
		-- 注册全局效果，用于在结束阶段将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果发动时的目标选择：以对方场上1只表侧表示怪兽为对象
function c93236220.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使作为对象的对方怪兽的攻击力·守备力下降因为此卡发动而除外的怪兽的各自原本数值
function c93236220.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk,def=e:GetLabel()
		atk=math.max(atk,0)
		def=math.max(def,0)
		-- 那只对方怪兽的攻击力·守备力下降因为这张卡发动而除外的怪兽的各自原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-def)
		tc:RegisterEffect(e2)
	end
end
-- 结束阶段将暂时除外的怪兽返回场上的效果处理函数
function c93236220.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
