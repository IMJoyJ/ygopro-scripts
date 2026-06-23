--妖精伝姫を語る者
-- 效果：
-- 光属性「妖精传姬」怪兽＋魔法师族怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「妖精王子」为素材作融合召唤的场合才能发动。对方场上的卡全部破坏，给与对方破坏数量×500伤害。
-- ②：自己的「妖精传姬」怪兽不会被战斗破坏。
-- ③：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把1张「妖精传姬」卡除外才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合召唤条件、破坏效果、战斗破坏免疫效果和无效效果
function s.initial_effect(c)
	-- 记录该卡为「妖精传姬」系列卡
	aux.AddCodeList(c,19144623)
	c:EnableReviveLimit()
	-- 设置融合召唤条件：必须使用「妖精传姬」属性为光的怪兽和魔法师族怪兽作为素材
	aux.AddFusionProcFun2(c,s.mfilter,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	-- ①：这张卡用「妖精王子」为素材作融合召唤的场合才能发动。对方场上的卡全部破坏，给与对方破坏数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：自己的「妖精传姬」怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把1张「妖精传姬」卡除外才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为所有「妖精传姬」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1db))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把1张「妖精传姬」卡除外才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 融合召唤时的过滤函数，判断是否为「妖精传姬」光属性怪兽
function s.mfilter(c,e,sp)
	return c:IsFusionSetCard(0x1db) and c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
-- 判断是否为融合召唤且使用了「妖精王子」作为素材
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置破坏效果的目标和伤害计算
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置给对方造成伤害的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- 执行破坏和伤害处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将对方场上所有卡破坏
		local ct=Duel.Destroy(g,REASON_EFFECT)
		if ct~=0 then
			-- 给对方造成破坏数量×500的伤害
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
		end
	end
end
-- 检查融合召唤时是否使用了「妖精王子」作为素材
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,19144623) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 无效效果发动时的条件判断
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方发动效果且该卡未在战斗中被破坏且该连锁可被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 无效效果发动时的除外卡过滤函数
function s.cfilter(c)
	return c:IsSetCard(0x1db) and c:IsAbleToRemoveAsCost()
end
-- 设置无效效果发动时的除外卡消耗
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「妖精传姬」卡可除外
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的「妖精传姬」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置无效效果发动时的处理信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏发动卡的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效效果发动的处理
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效发动且发动卡仍有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
