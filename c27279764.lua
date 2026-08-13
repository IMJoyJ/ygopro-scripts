--アポクリフォート・キラー
-- 效果：
-- 这张卡不能特殊召唤，把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
-- ①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ②：只要这张卡在怪兽区域存在，特殊召唤的怪兽的攻击力·守备力下降500。
-- ③：1回合1次，自己主要阶段才能发动。对方必须把自身的手卡·场上1只怪兽送去墓地。
function c27279764.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c27279764.tlimit)
	c:RegisterEffect(e2)
	-- 把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
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
	-- ①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(c27279764.immcon)
	e5:SetValue(c27279764.efilter)
	c:RegisterEffect(e5)
	-- ②：只要这张卡在怪兽区域存在，特殊召唤的怪兽的攻击力·守备力下降500。
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
	-- ③：1回合1次，自己主要阶段才能发动。对方必须把自身的手卡·场上1只怪兽送去墓地。
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(c27279764.tgtg)
	e8:SetOperation(c27279764.tgop)
	c:RegisterEffect(e8)
end
-- 该函数用于设置这张卡的解放素材限制：非「机壳」（0xaa）怪兽返回true，表示不能作为这张卡的解放素材。
function c27279764.tlimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 该函数是这张卡的召唤手续条件：当c为nil时无条件允许；否则需要所需祭品数不超过3，且场上存在至少3只可解放的怪兽。
function c27279764.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤手续是否可行：所需祭品数不超过3，且通过Duel.CheckTribute确认场上存在至少3只可解放的祭品。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 该函数执行召唤手续：选择3只解放素材，将其设为这张卡的召唤素材并解放。
function c27279764.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让当前玩家选择3只怪兽作为这张卡上级召唤的祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的3只怪兽以召唤和素材为由解放（REASON_SUMMON+REASON_MATERIAL），完成上级召唤的解放代价。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 免疫效果的条件：这张卡以通常召唤（SUMMON_TYPE_NORMAL）出场时才适用①的免疫效果。
function c27279764.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 免疫过滤函数：来袭效果是魔法·陷阱卡则直接免疫；否则调用aux.qlifilter判断是否为原本等级/阶级低于这张卡的怪兽发动的效果。
function c27279764.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	-- 对于非魔法·陷阱卡的怪兽效果，使用aux.qlifilter判断是否因原本等级/阶级低于本卡而获得免疫。
	else return aux.qlifilter(e,te) end
end
-- 攻守下降效果的对象筛选：只对特殊召唤（SUMMON_TYPE_SPECIAL）的怪兽适用。
function c27279764.adtg(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 手卡送墓筛选：非公开的手卡可直接选择；公开的卡则必须是怪兽，用于③效果中对方选择手卡·场上1只怪兽。
function c27279764.tgfilter(c)
	return not c:IsPublic() or c:IsType(TYPE_MONSTER)
end
-- ③效果的发动条件与操作信息设置：对方场上有怪兽或手卡存在可送去墓地的卡时才能发动；发动后设置将对方手卡·场上1只怪兽送去墓地的操作信息。
function c27279764.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上（LOCATION_MZONE）的怪兽数量，用于判断③效果能否发动。
	local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 获取对方手卡（LOCATION_HAND）中的所有卡，用于检查是否存在可送去墓地的卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return mc>0 or g and g:IsExists(c27279764.tgfilter,1,nil) end
	-- 设置本次效果的操作信息：将对方手卡·场上1只怪兽送去墓地（CATEGORY_TOGRAVE，数量1，目标位置为对方怪兽区域+手卡）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ③效果处理：对方从自身场上和手卡中选择1只怪兽送去墓地。
function c27279764.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上及手卡中所有怪兽的集合，作为可选择送去墓地的候选。
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_MZONE+LOCATION_HAND,0,nil,TYPE_MONSTER)
	if g:GetCount()>0 then
		-- 向对方玩家显示选择提示，要求其选择1只要送去墓地的怪兽。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 为对方选择的卡播放选中动画，并记录该卡被本次效果选中。
		Duel.HintSelection(sg)
		-- 将选择的卡以规则理由（REASON_RULE）送去对方玩家的墓地。
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
