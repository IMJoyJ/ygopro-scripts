--No.104 仮面魔踏士シャイニングV
-- 效果：
-- 4星怪兽×3
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「异晶人的」魔法·陷阱卡加入手卡。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡超量召唤的场合发动。对方可以从自身卡组把4只怪兽（相同属性最多1只）和1张魔法卡除外。没除外的场合，自己从对方卡组上面把10张卡除外。
local s,id,o=GetID()
-- 初始化函数：设置超量召唤手续和苏生限制，注册①检索效果和②作为超量素材时赋予效果的处理
function s.initial_effect(c)
	-- 为这张卡设置超量召唤手续：用3只4星怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1张「异晶人的」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
-- 注册这张卡的No.编号为104（用于「No.」相关的判定）
aux.xyz_number[id]=104
-- ①效果的代价：把这张卡1个超量素材取除
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：是「异晶人的」魔法·陷阱卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x176) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的目标：检查卡组中是否存在可加入手卡的「异晶人的」魔法·陷阱卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的可加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从自己卡组把1张卡加入手卡（CATEGORY_TOHAND）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从自己卡组选择1张「异晶人的」魔法·陷阱卡加入手卡，并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足条件的「异晶人的」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的触发条件：这张卡是作为超量召唤的素材被取除（REASON_XYZ）
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- ②效果的处理：给用这张卡作素材超量召唤的怪兽注册一个超量召唤成功时强制发动的除外效果；若该怪兽原本不是效果怪兽则为其追加效果怪兽属性
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡超量召唤的场合发动。对方可以从自身卡组把4只怪兽（相同属性最多1只）和1张魔法卡除外。没除外的场合，自己从对方卡组上面把10张卡除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,2))  --"除外效果（No.104 假面魔蹈士 闪光V枉然）"
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
		-- ●这张卡超量召唤的场合发动。对方可以从自身卡组把4只怪兽（相同属性最多1只）和1张魔法卡除外。没除外的场合，自己从对方卡组上面把10张卡除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 除外效果的发动条件：被特殊召唤的怪兽中包含这张卡且这次特殊召唤是超量召唤
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 除外效果的目标：向对方提示发动的效果，并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示：对方选择了发动此除外效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预计从对方卡组除外1张以上的卡（CATEGORY_REMOVE）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 过滤条件：是怪兽卡或魔法卡且可以被除外
function s.rmfilter(c,tp)
	return c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToRemove(tp)
end
-- 子卡组检查：选出的5张卡必须恰好包含1张魔法卡和4只怪兽，且怪兽属性互不相同
function s.gcheck(g)
	if g:FilterCount(Card.IsType,nil,TYPE_SPELL)~=1 then return false end
	local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	if sg:GetCount()~=4 then return false end
	-- 检查这4只怪兽的属性是否互不相同（相同属性最多1只）
	return aux.dabcheck(sg)
end
-- 追加检查：选出的卡中魔法卡不超过1张、怪兽不超过4只，且怪兽属性互不相同
function s.rmgcheck(g)
	if g:FilterCount(Card.IsType,nil,TYPE_SPELL)>1 then return false end
	local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	if #sg>4 then return false end
	-- 检查所选怪兽的属性是否互不相同（相同属性最多1只）
	return aux.dabcheck(sg)
end
-- 除外效果的处理：对方卡组中可组成「4只不同属性怪兽+1张魔法卡」的组合时，让对方选择是否将其除外；除外则将所选卡表侧表示除外，没除外的场合自己从对方卡组上面把10张卡表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方卡组中所有可被除外的怪兽卡和魔法卡
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_DECK,nil,1-tp)
	-- 设置子卡组选择的追加检查函数（限制魔法卡最多1张、怪兽最多4只且属性互不相同）
	aux.GCheckAdditional=s.rmgcheck
	local res=g:IsExists(Card.IsType,1,nil,TYPE_SPELL) and g:CheckSubGroup(s.gcheck,5,5)
	-- 若存在满足条件的5张组合，则询问对方：是否把4只怪兽和1张魔法卡除外？
	if res and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then  --"是否把4只怪兽和1张魔法卡除外？"
		-- 向对方发送提示：请选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:SelectSubGroup(1-tp,s.gcheck,false,5,5)
		-- 清除子卡组选择的追加检查函数
		aux.GCheckAdditional=nil
		if sg then
			-- 把对方选择的4只怪兽和1张魔法卡以表侧表示除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	else
		-- 清除子卡组选择的追加检查函数
		aux.GCheckAdditional=nil
		-- 取得对方卡组最上方的10张卡
		local sg=Duel.GetDecktopGroup(1-tp,10)
		if #sg<=0 then return end
		-- 使接下来的除外操作不触发卡组洗切检查（因为是从卡组顶端除外）
		Duel.DisableShuffleCheck()
		-- 把对方卡组最上方的10张卡以表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
