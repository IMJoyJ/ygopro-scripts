--原石竜ネザー・ベルセリウス
-- 效果：
-- 「原石」怪兽＋通常怪兽1只以上
-- ①：这张卡的攻击力上升作为这张卡的融合素材的通常怪兽数量×1000。
-- ②：只要这张卡在怪兽区域存在，等级·阶级·连接的数值是自己的场上·墓地的通常怪兽数量以下的对方场上的怪兽发动的效果无效化。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只通常怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制，设置融合召唤条件，注册材质检查效果，注册连锁无效化效果，注册墓地发动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤条件：以1只「原石」怪兽为融合素材，再以1到127只通常怪兽为融合素材
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1b9),aux.FilterBoolFunction(Card.IsFusionType,TYPE_NORMAL),1,127,true)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只通常怪兽守备表示特殊召唤。
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
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的通常怪兽数量×1000。
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
-- 计算融合素材中通常怪兽数量，并为自身增加相应攻击力
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
-- 过滤器函数，用于筛选场上正面表示且未被战斗破坏或禁用的怪兽
function s.disfilter(c)
	return c:IsFaceup() and not c:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsDisabled()
end
-- 连锁无效化条件判断函数，判断是否满足无效化条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 统计自己场上和墓地的通常怪兽数量
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceupEx,Card.IsType),tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,TYPE_NORMAL)
	-- 获取当前连锁的触发玩家、位置、等级、阶级信息
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
-- 连锁无效化操作函数，使连锁效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，显示该卡发动了效果
	Duel.Hint(HINT_CARD,0,id)
	-- 使当前连锁效果无效
	Duel.NegateEffect(ev)
end
-- 墓地发动效果的发动条件判断函数，判断该卡是否从场上送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选可以特殊召唤的通常怪兽
function s.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标函数，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的通常怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，从卡组选择一只通常怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择一只满足条件的通常怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的通常怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
