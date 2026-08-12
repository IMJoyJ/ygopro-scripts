--天魔神 インヴィシル
-- 效果：
-- 这张卡不能特殊召唤。为这张卡的上级召唤而解放的怪兽的种族和属性让这张卡得到以下效果。
-- ●天使族·光属性：只要这张卡在场上表侧表示存在，场上的魔法卡的效果无效。
-- ●恶魔族·暗属性：只要这张卡在场上表侧表示存在，场上的陷阱卡的效果无效。
function c74841885.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 为这张卡的上级召唤而解放的怪兽的种族和属性让这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c74841885.valcheck)
	c:RegisterEffect(e2)
	-- 为这张卡的上级召唤而解放的怪兽的种族和属性让这张卡得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetOperation(c74841885.facechk)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤条件：检查怪兽是否满足指定的种族和属性
function c74841885.chkfilter(c,rac,att)
	return c:IsRace(rac) and c:IsAttribute(att)
end
-- 检查上级召唤解放的怪兽，根据其种族和属性赋予对应的无效化效果
function c74841885.valcheck(e,c)
	if e:GetLabel()~=1 then return end
	e:SetLabel(0)
	local g=c:GetMaterial()
	local lbl=0
	if g:IsExists(c74841885.chkfilter,1,nil,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		lbl=lbl+TYPE_SPELL
	end
	if g:IsExists(c74841885.chkfilter,1,nil,RACE_FIEND,ATTRIBUTE_DARK) then
		lbl=lbl+TYPE_TRAP
	end
	if lbl~=0 then
		-- ●天使族·光属性：只要这张卡在场上表侧表示存在，场上的魔法卡的效果无效。 / ●恶魔族·暗属性：只要这张卡在场上表侧表示存在，场上的陷阱卡的效果无效。
		local e1=Effect.CreateEffect(c)
		if lbl==TYPE_SPELL then
			e1:SetDescription(aux.Stringid(74841885,0))  --"魔法卡的效果无效"
		elseif lbl==TYPE_TRAP then
			e1:SetDescription(aux.Stringid(74841885,1))  --"陷阱卡的效果无效"
		else
			e1:SetDescription(aux.Stringid(74841885,2))  --"魔法和陷阱卡的效果无效"
		end
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
		e1:SetTarget(c74841885.distg)
		e1:SetLabel(lbl)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
		-- ●天使族·光属性：只要这张卡在场上表侧表示存在，场上的魔法卡的效果无效。 / ●恶魔族·暗属性：只要这张卡在场上表侧表示存在，场上的陷阱卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetRange(LOCATION_MZONE)
		e2:SetLabel(lbl)
		e2:SetOperation(c74841885.disop)
		e2:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e2)
		if bit.band(lbl,TYPE_TRAP)~=0 then
			-- ●恶魔族·暗属性：只要这张卡在场上表侧表示存在，场上的陷阱卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetRange(LOCATION_MZONE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(c74841885.distg)
			e3:SetLabel(TYPE_TRAP)
			e3:SetReset(RESET_EVENT+0xff0000)
			c:RegisterEffect(e3)
		end
	end
end
-- 无效化过滤：确定需要无效化的卡片类型（魔法或陷阱）
function c74841885.distg(e,c)
	return c:IsType(e:GetLabel())
end
-- 在连锁处理时，无效化在魔陷区发动的对应类型的卡的效果
function c74841885.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_SZONE)~=0 and re:IsActiveType(e:GetLabel()) then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 在进行表侧表示上级召唤时，标记需要进行解放怪兽的素材检查
function c74841885.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
