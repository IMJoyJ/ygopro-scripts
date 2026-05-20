--霧の王
-- 效果：
-- 这张卡召唤的场合，可以用1只祭品或者不用祭品作召唤。这张卡的攻击力变成祭品召唤时作为祭品的怪兽的原本攻击力合计数值。只要这张卡在场上表侧表示存在，任何形式的祭品都不能进行。
function c6614221.initial_effect(c)
	-- 这张卡召唤的场合，可以用1只祭品或者不用祭品作召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(6614221,0))  --"用1只祭品召唤"
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(c6614221.ttcon)
	e0:SetOperation(c6614221.ttop)
	e0:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e0)
	-- 或者不用祭品作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6614221,1))  --"不用祭品作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c6614221.ntcon)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力变成祭品召唤时作为祭品的怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c6614221.valcheck)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力变成祭品召唤时作为祭品的怪兽的原本攻击力合计数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetOperation(c6614221.facechk)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，任何形式的祭品都不能进行。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	c:RegisterEffect(e4)
end
-- 不用祭品作召唤的条件过滤函数
function c6614221.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足不用祭品召唤的条件（需要0个祭品、自身等级在5星以上且怪兽区域有空位）
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 用1只祭品作召唤的条件过滤函数
function c6614221.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足用1只祭品召唤的条件（需要最多1个祭品且场上有可解放的怪兽）
	return minc<=1 and Duel.CheckTribute(c,1)
end
-- 用1只祭品作召唤的具体操作函数
function c6614221.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只用于召唤该卡的祭品怪兽
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	-- 解放选中的怪兽作为召唤素材
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查作为祭品的怪兽并计算其原本攻击力合计数值的函数
function c6614221.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	while tc do
		local catk=tc:GetTextAttack()
		atk=atk+(catk>=0 and catk or 0)
		tc=g:GetNext()
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 这张卡的攻击力变成祭品召唤时作为祭品的怪兽的原本攻击力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
	end
end
-- 在召唤时将标记设为1，用于触发后续的攻击力改变效果
function c6614221.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
