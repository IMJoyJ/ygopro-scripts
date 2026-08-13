--原石竜ネザー・ベルセリウス
-- 效果：
-- 「原石」怪兽＋通常怪兽1只以上
-- ①：这张卡的攻击力上升作为这张卡的融合素材的通常怪兽数量×1000。
-- ②：只要这张卡在怪兽区域存在，等级·阶级·连接的数值是自己的场上·墓地的通常怪兽数量以下的对方场上的怪兽发动的效果无效化。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只通常怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 为这张卡注册效果：设定融合召唤限制与融合素材条件，并注册①基于素材中通常怪兽数量的攻击力上升效果、②无效对方低数值怪兽发动效果的永续效果、③从场上送入墓地时从卡组守备表示特殊召唤通常怪兽的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「原石」怪兽和1只以上通常怪兽为融合素材（上限127只表示不限制数量），满足条件即可进行融合召唤。
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1b9),aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),1,127,true)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的通常怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，等级·阶级·连接的数值是自己的场上·墓地的通常怪兽数量以下的对方场上的怪兽发动的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只通常怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 素材检查函数：在融合召唤成功时统计作为素材的通常怪兽数量，并为这张卡生成一个攻击力上升（数量×1000）的效果，该效果在怪兽离场后重置。
function s.matcheck(e,c)
	local ct=c:GetMaterial():Filter(Card.IsType,nil,TYPE_NORMAL):GetCount()
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的通常怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ct*1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 定义过滤器：筛选表侧表示、未被战斗破坏确定且未被无效化的怪兽，作为判断可被无效对象的条件。
function s.disfilter(c)
	return c:IsFaceup() and not c:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsDisabled()
end
-- ②效果的发动条件：对方从怪兽区域发动的怪兽效果，且该怪兽的等级/阶级/连接数值≤己方场上·墓地的通常怪兽数量，同时本卡不处于战斗破坏状态时，条件成立。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 统计己方场上表侧表示及墓地中的通常怪兽数量，作为②效果判定数值大小的基准。
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceupEx,Card.IsType),tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,TYPE_NORMAL)
	-- 获取当前连锁中触发效果怪兽的控制者、发动位置、等级与阶级，用于后续判断是否为对方场上怪兽以及数值比较。
	local p,loc,lv,rk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_LEVEL,CHAININFO_TRIGGERING_RANK)
	if not (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and p==1-tp and not c:IsStatus(STATUS_BATTLE_DESTROYED)) then
		return false
	end
	if lv>0 then
		if ct>=lv then return true end
	elseif rk>0 then
		if ct>=rk then return true end
	elseif re:IsActiveType(TYPE_LINK) then
		if rc:IsLinkBelow(ct) then return true end
	end
end
-- ②效果的处理：向双方展示这张卡，并将当前连锁中符合条件的对方怪兽效果无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡的发动动画/提示，用于告知对方此次无效效果由这张卡处理。
	Duel.Hint(HINT_CARD,0,id)
	-- 将当前连锁中触发的那一个对方怪兽效果无效化。
	Duel.NegateEffect(ev)
end
-- ③效果的发动条件：该卡此前位于场上区域（即从场上被送去墓地），满足“从场上送去墓地的场合”。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果的特招对象筛选：从卡组选择1只通常怪兽，且该怪兽可以以表侧守备表示特殊召唤。
function s.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的发动阶段检查：确认己方主要怪兽区有空位，且卡组中存在可特殊召唤的通常怪兽，满足才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有至少1个空位，以保证特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足筛选条件的通常怪兽，从而确定③效果能否发动。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：声明本效果将进行特殊召唤，处理时从卡组特殊召唤1只怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：在主要怪兽区有空位时，从卡组选择1只符合条件的通常怪兽，以表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认主要怪兽区仍有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选出1只满足条件的通常怪兽作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的通常怪兽以表侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
