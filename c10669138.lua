--L・G・D
-- 效果：
-- 怪兽5只
-- 这张卡不用连接召唤不能特殊召唤。
-- ①：这张卡用暗·地·水·炎·风属性全部为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。
-- ②：场上的这张卡不受其他卡的效果影响，不会被和暗·地·水·炎·风属性怪兽的战斗破坏。
-- ③：对方结束阶段发动。从自己墓地选5张卡里侧表示除外。不能让5张除外的场合，这张卡送去墓地。
function c10669138.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要5个素材进行连接召唤
	aux.AddLinkProcedure(c,nil,5,5)
	-- 这张卡不用连接召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过连接召唤
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	-- 连接素材检查效果，用于记录连接素材的属性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c10669138.matcheck)
	c:RegisterEffect(e2)
	-- ①：这张卡用暗·地·水·炎·风属性全部为素材作连接召唤成功的场合才能发动。对方场上的卡全部破坏。
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
	-- ②：场上的这张卡不受其他卡的效果影响，不会被和暗·地·水·炎·风属性怪兽的战斗破坏。
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
	-- ③：对方结束阶段发动。从自己墓地选5张卡里侧表示除外。不能让5张除外的场合，这张卡送去墓地。
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
-- 检查连接素材属性的函数
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
-- 判断是否满足效果①发动条件的函数
function c10669138.descon(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and att&ATTRIBUTE_DARK>0
		and att&ATTRIBUTE_EARTH>0 and att&ATTRIBUTE_WATER>0
		and att&ATTRIBUTE_FIRE>0 and att&ATTRIBUTE_WIND>0
end
-- 设置效果①目标的函数
function c10669138.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①发动条件的函数
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有卡的组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果①破坏操作的函数
function c10669138.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有卡的组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果免疫过滤函数
function c10669138.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 判断是否不会被战斗破坏的函数
function c10669138.indes(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
end
-- 判断是否满足效果③发动条件的函数
function c10669138.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 设置效果③目标的函数
function c10669138.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定除外5张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,tp,LOCATION_GRAVE)
	-- 设置连锁操作信息，指定将自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 执行效果③除外操作的函数
function c10669138.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	-- 获取墓地中可除外的卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil,tp,POS_FACEDOWN)
	if g:GetCount()>=5 then
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		-- 选择5张卡进行除外
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,5,5,nil,tp,POS_FACEDOWN)
		-- 将选中的卡除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		-- 判断是否成功除外5张卡
		if Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==5 then res=true end
	end
	if not res and c:IsRelateToEffect(e) then
		-- 将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
