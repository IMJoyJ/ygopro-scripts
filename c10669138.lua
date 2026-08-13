--L・G・D
-- 效果：
-- 怪兽5只
-- 这张卡不用连接召唤不能特殊召唤。
-- ①：这张卡用暗·地·水·炎·风属性全部为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：场上的这张卡不受其他卡的效果影响，不会被和暗·地·水·炎·风属性怪兽的战斗破坏。
-- ③：对方结束阶段发动。从自己墓地选5张卡里侧表示除外。不能让5张除外的场合，这张卡送去墓地。
function c10669138.initial_effect(c)
	c:EnableReviveLimit()
	-- 为连神龙添加连接召唤手续：素材为任意5只怪兽（不限制种族/属性），且必须是刚好5只。
	aux.AddLinkProcedure(c,nil,5,5)
	-- “这张卡不用连接召唤不能特殊召唤。”——设置特殊召唤条件：仅允许通过连接召唤特殊召唤，其他特殊召唤方式均不允许。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定值为aux.linklimit，即只有以连接召唤（SUMMON_TYPE_LINK）方式特殊召唤时才满足条件，从而禁止连接召唤以外的方式特殊召唤。
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	-- “这张卡用暗·地·水·炎·风属性全部为素材作连接召唤成功的场合才能发动。”——注册素材检查效果，用于记录本次连接召唤使用的素材属性集合，为①效果的发动条件做铺垫。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c10669138.matcheck)
	c:RegisterEffect(e2)
	-- “①：这张卡用暗·地·水·炎·风属性全部为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。”——注册①效果：暗地水炎风五种属性素材集齐并连接召唤成功时，破坏对方场上所有卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10669138,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c10669138.descon)
	e3:SetTarget(c10669138.destg)
	e3:SetOperation(c10669138.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- “②：场上的这张卡不受其他卡的效果影响” ——注册②效果中的效果免疫部分：使自己不受其他卡发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c10669138.efilter)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(c10669138.indes)
	c:RegisterEffect(e5)
	-- “③：对方结束阶段发动。从自己墓地选5张卡里侧表示除外。不能让5张除外的场合，这张卡送去墓地。”——注册③诱发必发效果：在对方结束阶段从自己墓地选5张里侧除外，不能除满5张则自身送墓。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(10669138,1))
	e6:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c10669138.rmcon)
	e6:SetTarget(c10669138.rmtg)
	e6:SetOperation(c10669138.rmop)
	c:RegisterEffect(e6)
end
-- 素材检查函数：获取本次连接召唤所用素材，将每只素材的连接标记属性按位或累加，最终把素材属性的并集存入效果e2的Label，供①效果发动条件判断是否包含暗地水炎风五种属性。
function c10669138.matcheck(e,c)
	local g=c:GetMaterial()
	local att=0
	local tc=g:GetFirst()
	while tc do
		att=att|tc:GetLinkAttribute()
		tc=g:GetNext()
	end
	e:SetLabel(att)
end
-- ①效果的发动条件判断：只有本卡以连接召唤成功，且之前记录的素材属性并集att同时包含暗、地、水、炎、风五种属性（分别按位与>0）时，才允许发动破坏效果。
function c10669138.descon(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and att&ATTRIBUTE_DARK>0
		and att&ATTRIBUTE_EARTH>0 and att&ATTRIBUTE_WATER>0
		and att&ATTRIBUTE_FIRE>0 and att&ATTRIBUTE_WIND>0
end
-- ①效果的发动目标设置：在发动时检查对方场上是否有卡存在，若有则获取对方场上全部卡，并设置后续破坏全部这些卡的操作信息。
function c10669138.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认对方场上至少存在1张卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上当前存在的所有卡（包含怪兽区和魔陷区）作为组g，用于设定破坏对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置本次连锁的操作信息为破坏效果：对象为对方场上全部卡g，破坏数量为g的卡数，使其他卡能正确响应这次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理时的实际运作：再次获取对方场上当前全部卡，并以效果原因将它们全部破坏。
function c10669138.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理阶段重新获取对方场上全部卡，保证破坏对象是处理时仍存在于场上的卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以REASON_EFFECT（效果原因）破坏组g中的全部卡。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ②效果免疫的过滤函数：仅当发动效果的那张卡的持有者（te:GetOwner()）与连神龙不同时，才视为‘其他卡的效果’，即不免疫自身效果。
function c10669138.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- ②战斗破坏抗性的过滤函数：如果战斗对象c的属性为暗、地、水、炎、风中的任意一种，则连神龙不会被该次战斗破坏。
function c10669138.indes(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
end
-- ③效果的发动条件：当前回合玩家为连神龙控制者的对方（1-tp），即只在对方回合才满足发动条件。
function c10669138.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家，若是则返回true，满足③“对方结束阶段”的发动时机要求。
	return Duel.GetTurnPlayer()==1-tp
end
-- ③效果发动时的目标/操作信息设置：本效果至少可以宣言发动（chk==0返回true），并预置除外5张自己墓地卡和自身送去墓地这两项操作信息。
function c10669138.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将从自己（tp）墓地除外5张卡，具体卡片在处理时选择，因此对象为nil。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,tp,LOCATION_GRAVE)
	-- 设置操作信息：若未能除外5张，则将效果持有者连神龙自身送去墓地（CATEGORY_TOGRAVE），对象明确为连神龙。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ③效果处理时的实际运作：从自己墓地选5张里侧表示除外，若实际除外数量确实为5则res为true；否则在连神龙仍与效果关联时将其送去墓地。
function c10669138.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	-- 获取自己墓地中所有可以被里侧表示除外的卡，用于判断墓地中是否有足够5张可除外。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	if g:GetCount()>=5 then
		-- 发送选择提示消息，提示玩家tp需要选择要除外的卡（HINTMSG_REMOVE），并打开选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家tp从自己墓地选择恰好5张满足可里侧除外条件的卡，作为本次除外的对象sg。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,5,5,nil,tp,POS_FACEDOWN)
		-- 将选中的sg以里侧表示（POS_FACEDOWN）从墓地除外，原因REASON_EFFECT。
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		-- 检查刚才的操作实际被除外且目前在除外区域的卡数量是否等于5，若是则res=true，表示成功除外5张。
		if Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==5 then res=true end
	end
	if not res and c:IsRelateToEffect(e) then
		-- 当未能成功除外5张时，将连神龙自身以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
