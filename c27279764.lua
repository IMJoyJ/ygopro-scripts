--アポクリフォート・キラー
-- 效果：
-- 这张卡不能特殊召唤，把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
-- ①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ②：只要这张卡在怪兽区域存在，特殊召唤的怪兽的攻击力·守备力下降500。
-- ③：1回合1次，自己主要阶段才能发动。对方必须把自身的手卡·场上1只怪兽送去墓地。
function c27279764.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只「机壳」怪兽解放的场合才能通常召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c27279764.tlimit)
	c:RegisterEffect(e2)
	-- 把自己场上3只「机壳」怪兽解放的场合才能通常召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27279764,0))  --"把3只「机壳」怪兽解放"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetCondition(c27279764.ttcon)
	e3:SetOperation(c27279764.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e4)
	-- 通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(c27279764.immcon)
	e5:SetValue(c27279764.efilter)
	c:RegisterEffect(e5)
	-- 只要这张卡在怪兽区域存在，特殊召唤的怪兽的攻击力·守备力下降500。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c27279764.adtg)
	e6:SetValue(-500)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
	-- 1回合1次，自己主要阶段才能发动。对方必须把自身的手卡·场上1只怪兽送去墓地。
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(c27279764.tgtg)
	e8:SetOperation(c27279764.tgop)
	c:RegisterEffect(e8)
end
-- 限制祭品必须为「机壳」怪兽，非「机壳」怪兽不能作为祭品。
function c27279764.tlimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 检查通常召唤条件，判断是否满足解放3只「机壳」怪兽的要求。
function c27279764.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断最小祭品数不超过3且场上存在3只可用的祭品。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 执行通常召唤操作，选择祭品并解放。
function c27279764.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3只祭品怪兽。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 以召唤和素材的原因解放所选的祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 检查这张卡是否是通过通常召唤出场的。
function c27279764.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 判断效果免疫条件：魔法·陷阱效果直接免疫，怪兽效果使用机壳通用抗性过滤。
function c27279764.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	-- 调用机壳通用抗性过滤函数，判断怪兽效果是否免疫。
	else return aux.qlifilter(e,te) end
end
-- 指定效果的目标为特殊召唤的怪兽。
function c27279764.adtg(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤条件：对方手卡中未公开的卡或怪兽卡。
function c27279764.tgfilter(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- 检查发动条件：对方场上有怪兽或手卡有怪兽，并设置送墓操作信息。
function c27279764.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算对方场上怪兽的数量。
	local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 获取对方手卡中的所有卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return mc>0 or g and g:IsExists(c27279764.tgfilter,1,nil) end
	-- 设置操作信息：效果处理时将一只怪兽从对方手卡或场上送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE+LOCATION_HAND)
end
-- 执行效果：让对方选择一只怪兽送去墓地。
function c27279764.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从对方手卡和场上筛选出所有怪兽卡。
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_MZONE+LOCATION_HAND,0,nil,TYPE_MONSTER)
	if g:GetCount()>0 then
		-- 向对方玩家提示选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 显示被选卡片的动画效果。
		Duel.HintSelection(sg)
		-- 将选择的怪兽送去墓地。
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
