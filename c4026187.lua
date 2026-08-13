--妖精伝姫を語る者
-- 效果：
-- 光属性「妖精传姬」怪兽＋魔法师族怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「妖精王子」为素材作融合召唤的场合才能发动。对方场上的卡全部破坏，给与对方破坏数量×500伤害。
-- ②：自己的「妖精传姬」怪兽不会被战斗破坏。
-- ③：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·墓地把1张「妖精传姬」卡除外才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 注册卡片所有效果：设置召唤限制与融合手续，并注册①③效果及永续②效果。
function s.initial_effect(c)
	-- 告知引擎此卡卡名中记载着卡号19144623（妖精王子），用于后续判断是否以其为融合素材。
	aux.AddCodeList(c,19144623)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：可以以1只光属性「妖精传姬」怪兽和1只魔法师族怪兽为融合素材进行融合召唤。
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
	-- 用「妖精王子」为素材作融合召唤的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：自己的「妖精传姬」怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置②效果的适用对象：只对我方场上拥有「妖精传姬」字段的怪兽生效。
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
-- 融合素材怪兽过滤：必须为光属性且字段为「妖精传姬」的怪兽，即满足“光属性「妖精传姬」怪兽”这一素材要求。
function s.mfilter(c,e,sp)
	return c:IsFusionSetCard(0x1db) and c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
-- ①效果发动条件：素材检查的标记为1（确实使用了「妖精王子」作为素材）且这张卡是融合召唤成功时。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果发动时的目标处理：获取对方场上的所有卡，若存在则设置破坏与伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的全部卡（无条件过滤），用于后续破坏和计算数量。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：声明将破坏对方场上的全部卡，数量为当前获取的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：声明将给与对方（1-tp）伤害，数值为对方场上卡数量×500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*500)
end
-- ①效果处理：重新获取对方场上所有卡，全部破坏，并按实际破坏数量给与对方×500的伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上的全部卡（因可能受连锁影响而数量变化）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏对方场上的全部卡，并返回实际被破坏的数量ct。
		local ct=Duel.Destroy(g,REASON_EFFECT)
		if ct~=0 then
			-- 给与对方玩家实际破坏数量×500的效果伤害。
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
		end
	end
end
-- 素材检查的值设置：若融合素材中存在「妖精王子」（19144623），则将关联的①效果的标签设为1，否则为0，供发动条件判断。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,19144623) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ③效果发动条件：必须是对方发动的魔法·陷阱·怪兽效果（rp==1-tp），这张卡不在战斗破坏状态，且该连锁可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判断：对方效果发动、此卡未被战斗破坏、连锁可被无效，三者同时满足才可发动③效果。
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ③效果发动代价的过滤：手卡·墓地的卡需为「妖精传姬」字段且可以除外作为代价。
function s.cfilter(c)
	return c:IsSetCard(0x1db) and c:IsAbleToRemoveAsCost()
end
-- ③效果代价：从自己的手卡·墓地选择1张「妖精传姬」卡除外。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价是否可行：手卡·墓地是否存在至少1张符合条件的「妖精传姬」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示消息，让玩家选择要除外的「妖精传姬」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1张手卡·墓地的符合条件的「妖精传姬」卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外，作为发动③效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果的目标处理：无需取对象，直接设置将对方发动的效果无效并破坏的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的卡（eg）标记为无效对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：当对方发动的卡可被破坏且与连锁相关时，将其标记为破坏对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：无效对方效果的发动，若成功且该卡仍与连锁相关，则将其破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行无效连锁操作，并检查该效果是否仍然关联当前连锁，以决定是否进行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以效果原因破坏被无效的对方发动的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
