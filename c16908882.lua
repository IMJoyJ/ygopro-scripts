--No.104 仮面魔踏士シャイニングV
local s,id,o=GetID()
-- 初始化效果，设置XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，需要4星且至少3只怪兽作为素材
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 这个效果的发动回数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这张卡被作为XYZ素材送去墓地时，可以发动以下效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为104
aux.xyz_number[id]=104
-- 检查并移除1张作为费用的叠加素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于检索满足条件的魔法陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x176) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 判断是否能检索满足条件的卡片，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果，选择并送入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡片组
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为XYZ召唤作为素材
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 处理效果，当此卡被作为XYZ素材时触发的效果
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 这张卡XYZ召唤成功时，可以发动以下效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 对方场上的怪兽以及魔法·陷阱卡从游戏中除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断是否为XYZ召唤成功且包含此卡的召唤者
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置操作信息，表示将要将卡除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择发动了什么效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要将卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤函数，用于检索可以除外的怪兽或魔法陷阱卡
function s.rmfilter(c,tp)
	return c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToRemove(tp)
end
-- 检查组是否满足条件：包含1张魔法卡和4只怪兽且属性不同
function s.gcheck(g)
	if g:FilterCount(Card.IsType,nil,TYPE_SPELL)~=1 then return false end
	local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	if sg:GetCount()~=4 then return false end
	-- 检查组中所有怪兽是否具有互不相同的属性
	return aux.dabcheck(sg)
end
-- 检查组是否满足条件：最多1张魔法卡和最多4只怪兽且属性不同
function s.rmgcheck(g)
	if g:FilterCount(Card.IsType,nil,TYPE_SPELL)>1 then return false end
	local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	if #sg>4 then return false end
	-- 检查组中所有怪兽是否具有互不相同的属性
	return aux.dabcheck(sg)
end
-- 处理效果，根据选择决定除外卡或从卡组顶部除外10张卡
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方卡组中所有可以除外的卡
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_DECK,nil,1-tp)
	-- 设置额外检查函数用于判断组合是否满足条件
	aux.GCheckAdditional=s.rmgcheck
	local res=g:IsExists(Card.IsType,1,nil,TYPE_SPELL) and g:CheckSubGroup(s.gcheck,5,5)
	-- 判断是否满足条件并询问对方是否发动效果
	if res and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:SelectSubGroup(1-tp,s.gcheck,false,5,5)
		-- 清除额外检查函数
		aux.GCheckAdditional=nil
		if sg then
			-- 将选中的卡片除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	else
		-- 清除额外检查函数
		aux.GCheckAdditional=nil
		-- 获取对方卡组最上方的10张卡
		local sg=Duel.GetDecktopGroup(1-tp,10)
		if #sg<=0 then return end
		-- 禁止洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 将选中的卡除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
