--御巫奉サナキ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己场上1张「御巫」卡为对象才能发动。那张卡回到手卡。
-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1只幻想魔族以外的「御巫」怪兽特殊召唤。这个回合，自己不是「御巫」怪兽不能从额外卡组特殊召唤。
-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果的发动条件和处理
function s.initial_effect(c)
	-- ①：以自己场上1张「御巫」卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1只幻想魔族以外的「御巫」怪兽特殊召唤。这个回合，自己不是「御巫」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_EQUIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"装备"
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
-- 定义①效果的过滤函数，用于判断是否为表侧表示的御巫卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18d) and c:IsAbleToHand()
end
-- ①效果的发动时点处理，选择目标并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查①效果是否可以发动，判断场上是否存在满足条件的御巫卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的御巫卡作为目标
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，表示将目标卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理函数，将目标卡返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义②效果的过滤函数，用于判断是否为符合条件的御巫怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsRace(RACE_ILLUSION)
end
-- ②效果的发动时点处理，检查是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的御巫怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，特殊召唤符合条件的御巫怪兽并设置限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的御巫怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 创建一个限制非御巫怪兽从额外卡组特殊召唤的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数，判断是否为非御巫怪兽且在额外卡组
function s.splimit(e,c)
	return not c:IsSetCard(0x18d) and c:IsLocation(LOCATION_EXTRA)
end
-- ③效果的发动时点处理，选择目标怪兽并设置操作信息
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在满足条件的表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的表侧表示怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，表示将此卡从墓地离开
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ③效果的处理函数，将此卡装备给目标怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToChain() or not c:CheckUniqueOnField(tp) then return end
	-- 执行装备操作
	if not Duel.Equip(tp,c,tc) then return end
	-- 创建装备限制效果，防止此卡被装备给其他怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(s.eqlimit)
	e2:SetLabelObject(tc)
	c:RegisterEffect(e2)
end
-- 装备限制效果的过滤函数，判断是否为装备对象怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
