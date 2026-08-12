--星輝士 トライヴェール
-- 效果：
-- 4星「星骑士」怪兽×3
-- 把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。
-- ①：这张卡超量召唤的场合发动。场上的其他卡全部回到手卡。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方手卡随机1张送去墓地。
-- ③：持有超量素材的这张卡被送去墓地的场合，以自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c42589641.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足条件的4星怪兽进行3次叠放
	aux.AddXyzProcedure(c,c42589641.xyzfilter,4,3)
	c:EnableReviveLimit()
	-- 把这张卡超量召唤的回合，自己不是「星骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c42589641.regcon)
	e1:SetOperation(c42589641.regop)
	c:RegisterEffect(e1)
	-- 自己不能把不是XYZ怪兽的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c42589641.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡超量召唤的场合发动。场上的其他卡全部回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42589641,0))  --"回到手卡"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c42589641.thcon)
	e3:SetTarget(c42589641.thtg)
	e3:SetOperation(c42589641.thop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。对方手卡随机1张送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42589641,1))  --"手卡破坏"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c42589641.hdcost)
	e4:SetTarget(c42589641.hdtg)
	e4:SetOperation(c42589641.hdop)
	c:RegisterEffect(e4)
	-- ③：持有超量素材的这张卡被送去墓地的场合，以自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42589641,2))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCondition(c42589641.spcon)
	e5:SetTarget(c42589641.sptg)
	e5:SetOperation(c42589641.spop)
	c:RegisterEffect(e5)
	if not c42589641.global_check then
		c42589641.global_check=true
		-- 注册全局效果，用于检测是否有非「星骑士」怪兽被特殊召唤
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c42589641.checkop)
		-- 将效果注册到玩家0
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历所有特殊召唤成功的怪兽，若其中存在非「星骑士」怪兽，则为对应玩家注册标识效果
function c42589641.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if not tc:IsSetCard(0x9c) then
			if tc:IsSummonPlayer(0) then p1=true else p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若玩家1有非「星骑士」怪兽被特殊召唤，则为玩家1注册标识效果
	if p1 then Duel.RegisterFlagEffect(0,42589641,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家2有非「星骑士」怪兽被特殊召唤，则为玩家2注册标识效果
	if p2 then Duel.RegisterFlagEffect(1,42589641,RESET_PHASE+PHASE_END,0,1) end
end
-- XYZ召唤条件函数，判断是否满足召唤条件
function c42589641.xyzfilter(c)
	-- 判断玩家未注册标识效果且怪兽为「星骑士」种族
	return Duel.GetFlagEffect(c:GetControler(),42589641)==0 and c:IsSetCard(0x9c)
end
-- 判断是否为XYZ召唤
function c42589641.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 注册不能特殊召唤非「星骑士」怪兽的效果
function c42589641.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册不能特殊召唤非「星骑士」怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42589641.sumlimit)
	-- 将效果注册到对应玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制非「星骑士」怪兽不能特殊召唤
function c42589641.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9c)
end
-- 限制非XYZ召唤不能特殊召唤
function c42589641.splimit(e,se,sp,st,spos,tgp)
	-- 判断是否为XYZ召唤或玩家未注册标识效果
	return bit.band(st,SUMMON_TYPE_XYZ)~=SUMMON_TYPE_XYZ or Duel.GetFlagEffect(tgp,42589641)==0
end
-- 判断是否为XYZ召唤
function c42589641.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置操作信息，准备将场上卡送回手牌
function c42589641.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有可送回手牌的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息，准备将场上卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将场上卡送回手牌
function c42589641.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可送回手牌的卡（排除自身）
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将卡送回手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
-- 支付代价，移除1个超量素材
function c42589641.hdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置操作信息，准备将对方手牌送去墓地
function c42589641.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0 end
	-- 设置操作信息，准备将对方手牌送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 随机选择对方手牌并送去墓地
function c42589641.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方所有手牌
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将卡送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
-- 判断是否持有超量素材且从场上被送去墓地
function c42589641.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousOverlayCountOnField()>0 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 筛选可特殊召唤的「星骑士」怪兽
function c42589641.spfilter(c,e,tp)
	return c:IsSetCard(0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤目标，准备选择墓地中的「星骑士」怪兽
function c42589641.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42589641.spfilter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否有可特殊召唤的「星骑士」怪兽
		and Duel.IsExistingTarget(c42589641.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「星骑士」怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c42589641.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c42589641.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
