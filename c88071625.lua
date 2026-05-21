--The tyrant NEPTUNE
-- 效果：
-- 这张卡不能特殊召唤。这张卡可以把1只怪兽解放作上级召唤。这张卡的攻击力·守备力上升上级召唤时解放的怪兽的原本的攻击力·守备力各自合计数值。这张卡上级召唤成功时，选择墓地存在的1只解放的效果怪兽，当作和那只怪兽同名卡使用，得到相同效果。
function c88071625.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终返回假（即不能特殊召唤）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只怪兽解放作上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88071625,0))  --"把1只怪兽解放召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c88071625.otcon)
	e2:SetOperation(c88071625.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
	-- 这张卡的攻击力·守备力上升上级召唤时解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c88071625.valcheck)
	c:RegisterEffect(e4)
	-- 这张卡的攻击力·守备力上升上级召唤时解放的怪兽的原本的攻击力·守备力各自合计数值。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetOperation(c88071625.facechk)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 这张卡上级召唤成功时，选择墓地存在的1只解放的效果怪兽，当作和那只怪兽同名卡使用，得到相同效果。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(88071625,1))  --"效果复制"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCondition(c88071625.copycon)
	e6:SetTarget(c88071625.copytg)
	e6:SetOperation(c88071625.copyop)
	c:RegisterEffect(e6)
end
-- 1只怪兽解放作上级召唤的允许条件判定函数。
function c88071625.otcon(e,c,minc)
	if c==nil then return true end
	-- 判定自身等级在7星以上、要求的最少解放怪兽数量不大于1，且场上存在至少1只可解放的怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 1只怪兽解放作上级召唤的具体执行操作函数。
function c88071625.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择1只用于上级召唤的解放怪兽。
	local sg=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(sg)
	-- 解放选择的怪兽作为上级召唤的素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查解放素材的原本攻击力与守备力，并在召唤成功时增加对应数值的攻击力与守备力。
function c88071625.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	local def=0
	while tc do
		local catk=tc:GetTextAttack()
		local cdef=tc:GetTextDefense()
		atk=atk+(catk>=0 and catk or 0)
		def=def+(cdef>=0 and cdef or 0)
		tc=g:GetNext()
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 这张卡的攻击力·守备力上升上级召唤时解放的怪兽的原本的攻击力·守备力各自合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
-- 召唤代价判定函数，用于标记该卡已进行通常召唤，从而允许触发素材检查的数值上升效果。
function c88071625.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
-- 复制效果的触发条件判定，必须是上级召唤成功。
function c88071625.copycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤出墓地中属于效果怪兽且可以作为效果对象的卡片。
function c88071625.filter(c,e)
	return c:IsType(TYPE_EFFECT) and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e)
end
-- 复制效果的对象选择与确认函数。
function c88071625.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetHandler():GetMaterial():IsContains(chkc) and c88071625.filter(chkc,e) end
	if chk==0 then return true end
	-- 给玩家发送选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=e:GetHandler():GetMaterial():FilterSelect(tp,c88071625.filter,1,1,nil,e)
	-- 将选中的怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(g)
end
-- 复制效果的具体执行操作函数，改变卡名并复制效果。
function c88071625.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetOriginalCode()
		-- 当作和那只怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
	end
end
