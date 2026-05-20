--皇たる水精鱗－ネプトアビス
-- 效果：
-- 包含鱼族·海龙族·水族怪兽的怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方不能把这张卡所连接区的水属性怪兽作为效果的对象。
-- ②：水属性怪兽为让卡的效果发动而被送去墓地的场合才能发动。从自己的卡组·墓地选1张「深渊」装备魔法卡加入手卡或给这张卡装备。
-- ③：这张卡被对方破坏的场合才能发动。从卡组把1只「海皇」怪兽或「水精鳞」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①的抗性效果、②的检索/装备效果、③的被破坏检索效果。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2到3只怪兽作为素材，且必须满足s.lcheck过滤条件。
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- ①：对方不能把这张卡所连接区的水属性怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.etlimit)
	-- 设置不能成为对方卡的效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：水属性怪兽为让卡的效果发动而被送去墓地的场合才能发动。从自己的卡组·墓地选1张「深渊」装备魔法卡加入手卡或给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏的场合才能发动。从卡组把1只「海皇」怪兽或「水精鳞」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：素材组中必须存在至少1只水族、鱼族或海龙族怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_AQUA+RACE_FISH+RACE_SEASERPENT)
end
-- 过滤①效果的影响对象：必须是这张卡所连接区的表侧表示水属性怪兽。
function s.etlimit(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsFaceup()
end
-- 过滤送去墓地的卡：作为卡的效果发动代价（COST）而被送去墓地的原本属性为水属性的怪兽。
function s.cfilter(c,tp,re)
	return c:IsReason(REASON_COST) and re:IsActivated() and c:GetOriginalAttribute()==ATTRIBUTE_WATER
end
-- ②效果的发动条件：有满足条件的水属性怪兽作为发动代价送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.cfilter,1,c,tp,re)
end
-- 过滤「深渊」装备魔法卡：可以加入手卡，或者在魔法与陷阱区有空位时可以装备给这张卡。
function s.eqfilter(c,tp,ec)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x75)
		and (c:IsAbleToHand() or c:CheckUniqueOnField(tp) and not c:IsForbidden()
		and c:CheckEquipTarget(ec)
		-- 检查自己场上的魔法与陷阱区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
-- ②效果的发动准备（Target）：检查卡组或墓地是否存在可操作的「深渊」装备魔法卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己的卡组或墓地是否存在至少1张满足条件的「深渊」装备魔法卡。
		return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp,e:GetHandler())
	end
end
-- ②效果的效果处理（Operation）：从卡组或墓地选择1张「深渊」装备魔法卡，选择将其加入手卡或装备给这张卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送提示信息：请选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「深渊」装备魔法卡（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp,c)
	local tc=g:GetFirst()
	if g:GetCount()>0 then
		if tc:CheckEquipTarget(c) and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			-- 如果该卡不能加入手卡，或者玩家在“加入手卡”与“装备”中选择了“装备”。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,aux.Stringid(id,3))==1) then  --"装备"
			-- 将选择的装备魔法卡装备给这张卡。
			Duel.Equip(tp,tc,c)
		else
			-- 将选择的卡加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ③效果的发动条件：这张卡在自己的控制下被对方破坏。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤要检索的怪兽：卡组中的「海皇」或「水精鳞」怪兽。
function s.thfilter2(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
		and c:IsSetCard(0x74,0x77)
end
-- ③效果的发动准备（Target）：检查卡组中是否存在可检索的怪兽，并设置操作信息为检索卡组。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组中是否存在至少1只「海皇」或「水精鳞」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的效果处理（Operation）：从卡组把1只「海皇」或「水精鳞」怪兽加入手卡。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「海皇」或「水精鳞」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
