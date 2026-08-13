--堕天使ゼラート
-- 效果：
-- 自己墓地有暗属性怪兽4种类以上存在的场合，这张卡可以把1只暗属性怪兽解放作上级召唤。
-- ①：从手卡把1只暗属性怪兽送去墓地才能发动。对方场上的怪兽全部破坏。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡破坏。
function c40921744.initial_effect(c)
	-- 自己墓地有暗属性怪兽4种类以上存在的场合，这张卡可以把1只暗属性怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40921744,0))  --"把1只暗属性怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c40921744.sumcon)
	e1:SetOperation(c40921744.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：从手卡把1只暗属性怪兽送去墓地才能发动。对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40921744,1))  --"对方场上存在的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c40921744.descost)
	e2:SetTarget(c40921744.destg)
	e2:SetOperation(c40921744.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡破坏。
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
-- 过滤函数：筛选可作为上级召唤解放的暗属性怪兽，要求为暗属性，且若为己方控制则不限表示形式，若为对方控制则必须是表侧表示。
function c40921744.mfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤规则效果的条件判定：本卡等级不低于7、所需解放数不超过1、场上存在可用的暗属性祭品，并且墓地中暗属性怪兽的卡名种类数不少于4。
function c40921744.sumcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上可作为祭品的暗属性怪兽集合，用于判断召唤手续是否满足。
	local mg=Duel.GetMatchingGroup(c40921744.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 获取自己墓地中所有暗属性怪兽的集合，用于统计种类数。
	local ag=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	-- 判定是否满足等级≥7、解放数为1且存在足够的暗属性祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
		and ag:GetClassCount(Card.GetCode)>=4
end
-- 召唤手续的执行：从可用的祭品中选择1只暗属性怪兽，将其设为素材并解放，完成上级召唤。
function c40921744.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 处理阶段重新获取双方场上可作为祭品的暗属性怪兽集合，确保选择时基于最新状态。
	local mg=Duel.GetMatchingGroup(c40921744.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从祭品候补中选择1只暗属性怪兽作为上级召唤的解放素材。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的暗属性怪兽解放，解放原因标记为召唤和作为上级召唤素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤函数：筛选手卡中可作为代价送去墓地的暗属性怪兽。
function c40921744.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：检查并支付从手卡丢弃1只暗属性怪兽的代价，并为本卡附加标记，用于在结束阶段触发②自毁效果。
function c40921744.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中是否存在至少1张符合条件的暗属性怪兽可以丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c40921744.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选择并丢弃1张符合条件的暗属性怪兽作为发动代价。
	Duel.DiscardHand(tp,c40921744.cfilter,1,1,REASON_COST)
	e:GetHandler():RegisterFlagEffect(40921744,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的目标/发动条件：确认对方场上有怪兽，并设置将对方场上全部怪兽破坏的操作信息。
function c40921744.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认对方场上存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上当前存在的全部怪兽，用于计算破坏数量。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果将破坏对方场上全部怪兽，破坏数量为怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：破坏对方场上的全部怪兽。
function c40921744.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取对方场上当前存在的全部怪兽，确保破坏的是最新状态下的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏对方场上全部怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ②自毁效果的发动条件：检查本卡是否带有①已发动的flag标记（即本回合发动过①效果）。
function c40921744.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(40921744)~=0
end
-- ②效果的目标函数：必发效果无需选择对象，设置将自身破坏的操作信息。
function c40921744.sdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将破坏这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ②效果处理：若本卡仍与效果关联且表侧表示，则将其破坏。
function c40921744.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果原因将这张卡自身破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
