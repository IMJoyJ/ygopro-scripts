--堕天使ゼラート
-- 效果：
-- 自己墓地有暗属性怪兽4种类以上存在的场合，这张卡可以把1只暗属性怪兽解放作上级召唤。
-- ①：从手卡把1只暗属性怪兽送去墓地才能发动。对方场上的怪兽全部破坏。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡破坏。
function c40921744.initial_effect(c)
	-- 上级召唤条件：自己墓地有暗属性怪兽4种类以上存在的场合，这张卡可以把1只暗属性怪兽解放作上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40921744,0))  --"把1只暗属性怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c40921744.sumcon)
	e1:SetOperation(c40921744.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 从手卡把1只暗属性怪兽送去墓地才能发动。对方场上的怪兽全部破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40921744,1))  --"对方场上存在的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c40921744.descost)
	e2:SetTarget(c40921744.destg)
	e2:SetOperation(c40921744.desop)
	c:RegisterEffect(e2)
	-- 这张卡的①的效果发动的回合的结束阶段发动。这张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40921744,2))  --"这张卡破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c40921744.sdescon)
	e3:SetTarget(c40921744.sdestg)
	e3:SetOperation(c40921744.sdesop)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回满足条件的暗属性怪兽（控制者或表侧表示）
function c40921744.mfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤条件判断函数：判断是否满足上级召唤条件（等级≥7、祭品满足、墓地暗属性怪兽数量≥4）
function c40921744.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足条件的暗属性怪兽组（用于上级召唤的祭品）
	local mg=Duel.GetMatchingGroup(c40921744.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 获取自己墓地所有暗属性怪兽组（用于判断种类数量）
	local ag=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	-- 判断是否满足上级召唤的祭品条件
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
		and ag:GetClassCount(Card.GetCode)>=4
end
-- 上级召唤操作函数：选择并解放1只暗属性怪兽作为祭品
function c40921744.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足条件的暗属性怪兽组（用于上级召唤的祭品）
	local mg=Duel.GetMatchingGroup(c40921744.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择1只暗属性怪兽作为上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤和素材原因解放选中的祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：返回可以作为代价送去墓地的暗属性怪兽
function c40921744.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动代价：丢弃1只暗属性怪兽到墓地，并记录flag
function c40921744.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1只暗属性怪兽的代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(c40921744.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1只暗属性怪兽到墓地作为代价
	Duel.DiscardHand(tp,c40921744.cfilter,1,1,REASON_COST)
	e:GetHandler():RegisterFlagEffect(40921744,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的目标设定：设置对方场上所有怪兽为破坏对象
function c40921744.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否对方场上存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有怪兽组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：破坏对方场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的处理函数：破坏对方场上所有怪兽
function c40921744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有怪兽组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏对方场上所有怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
-- ②效果的发动条件：判断是否在①效果发动的回合
function c40921744.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(40921744)~=0
end
-- ②效果的目标设定：设置自身为破坏对象
function c40921744.sdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：破坏自身
function c40921744.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果原因破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
