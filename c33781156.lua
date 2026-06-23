--鉄獣式撃滅兵装“Mouser”
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组·额外卡组把「铁兽式击灭兵装“捕鼠猫”」以外的2张「铁兽」卡送去墓地（同名卡最多1张）。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤条件并注册两个诱发效果
function s.initial_effect(c)
	-- 设置连接召唤所需的素材条件，需要2只同时具有兽族、兽战士族或鸟兽族种族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,2)
	c:EnableReviveLimit()
	-- 效果①：连接召唤成功时发动，从卡组或额外卡组将2张「铁兽」卡送去墓地（同名卡最多1张）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡被送去墓地时发动，选择场上1只表侧表示怪兽变为里侧守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件，判断是否为连接召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的「铁兽」卡，排除自身并确保能送去墓地
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x14d) and c:IsAbleToGrave()
end
-- 效果①的发动时的处理，检查是否有满足条件的卡组并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组，用于选择送去墓地的卡
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
	-- 设置操作信息，表示将有2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_EXTRA+LOCATION_DECK)
end
-- 效果①的处理，选择并送去墓地2张不同卡名的「铁兽」卡，并设置不能从额外卡组特殊召唤的效果
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 获取满足条件的卡组，用于选择送去墓地的卡
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	-- 检查卡组中是否存在2张不同卡名的卡组成的子组
	if g:CheckSubGroup(aux.dncheck,2,2) then
		-- 设置额外检查条件为卡名不同
		aux.GCheckAdditional=aux.dncheck
		-- 从卡组中选择2张不同卡名的卡
		local sg=g:SelectSubGroup(tp,aux.TRUE,false,2,2)
		-- 取消额外检查条件
		aux.GCheckAdditional=nil
		if sg and sg:GetCount()==2 then
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	-- 设置不能从额外卡组特殊召唤的效果，仅限非兽族·兽战士族·鸟兽族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 不能特殊召唤的限制条件，仅对额外卡组中非指定种族的怪兽生效
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- 过滤场上表侧表示且能变为里侧表示的怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的发动时处理，选择场上1只表侧表示怪兽作为对象
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 检查是否有满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将改变对象怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②的处理，将对象怪兽变为里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
