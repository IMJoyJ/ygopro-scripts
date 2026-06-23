--超電磁稼動ボルテック・ドラゴン
-- 效果：
-- 用以下的怪兽为祭品作祭品召唤的场合，这张卡得到各自的效果。
-- ●电池人-单1型：以这1张卡为对象的魔法·陷阱卡的效果无效。
-- ●电池人-单2型：这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
-- ●电池人-单3型：这张卡攻击力上升1000。
function c20529766.initial_effect(c)
	-- 注册一个在通常召唤成功时触发的效果，用于判断是否满足条件并执行后续操作
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c20529766.condition)
	e1:SetOperation(c20529766.operation)
	c:RegisterEffect(e1)
	-- 注册一个在召唤时检查素材的效果，用于标记使用的电池人怪兽类型
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c20529766.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 遍历召唤时使用的素材怪兽，根据其卡号设置对应的标志位
function c20529766.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetCode()
		if code==55401221 then flag=bit.bor(flag,0x1)
		elseif code==19733961 then flag=bit.bor(flag,0x2)
		elseif code==63142001 then flag=bit.bor(flag,0x4)
		end
		tc=g:GetNext()
	end
	e:GetLabelObject():SetLabel(flag)
end
-- 判断是否为上级召唤且已设置标志位，决定是否激活效果
function c20529766.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()~=0
end
-- 根据标志位为卡片注册对应的效果，包括无效魔法陷阱、贯穿伤害和攻击力上升
function c20529766.operation(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabel()
	local c=e:GetHandler()
	if bit.band(flag,0x1)~=0 then
		-- 创建一个在连锁处理时触发的效果，用于无效以自身为对象的魔法陷阱效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(c20529766.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		-- 创建一个使攻击无视防御力的效果，即贯穿伤害
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x4)~=0 then
		-- 创建一个使攻击力上升1000的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断连锁效果是否为魔法或陷阱卡，并且是否以自身为对象，若是则使其无效
function c20529766.disop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g:GetCount()==1 and g:GetFirst()==e:GetHandler() then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
