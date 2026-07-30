--Shamanite Shamanknight
local s,id,o=GetID()
-- 为卡片添加XYZ召唤手续并注册三个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为3、数量为2的怪兽进行超量召唤
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 效果1：当此卡特殊召唤成功时发动，可以将除外区的一张陷阱卡作为超量素材叠放
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(s.xyzcon2)
	c:RegisterEffect(e2)
	-- 效果3：场上的此卡可于战斗阶段发动，支付1个超量素材并宣言等级，从墓地或除外区特殊召唤1只暗属性怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为XYZ召唤成功
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤条件：对方场上存在的正面表示的陷阱卡
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsControler(tp)
end
-- 判断是否有对方场上的陷阱卡被除外
function s.xyzcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：可作为超量素材的除外区陷阱卡
function s.filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsCanOverlay()
end
-- 设置效果1的目标选择函数，选择除外区的陷阱卡作为超量素材
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查是否存在符合条件的除外区陷阱卡作为目标
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择目标陷阱卡作为超量素材
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler())
end
-- 效果1的处理函数，将选中的陷阱卡叠放至此卡上
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果1的目标卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 将目标陷阱卡叠放至此卡上
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 效果3的费用支付函数，需要支付1个超量素材并宣言等级
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取可特殊召唤的怪兽组（墓地或除外区）
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local lvt={}
	local res=false
	-- 遍历可特殊召唤的怪兽组
	for tc in aux.Next(g) do
		local tlv=tc:GetLevel()
		if e:GetHandler():CheckRemoveOverlayCard(tp,tlv,REASON_COST) then
			lvt[tlv]=tlv
		end
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then
			res=true
			lvt[i]=nil
			lvt[pc]=i
			pc=pc+1
		end
	end
	lvt[pc]=nil
	if chk==0 then return res end
	-- 提示玩家选择要宣言的等级
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	-- 玩家宣言一个等级
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveOverlayCard(tp,lv,lv,REASON_COST)
	e:SetLabel(lv)
end
-- 过滤条件：满足特殊召唤条件且属性为暗、等级符合要求的怪兽
function s.spfilter(c,e,tp,lv)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not lv or c:IsLevel(lv))
end
-- 设置效果3的目标选择函数，选择墓地或除外区的怪兽进行特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp,e:GetLabel()) end
	-- 检查场上是否有空位以及是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的怪兽作为目标
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽进行特殊召唤
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,e:GetLabel())
	-- 设置操作信息，确定特殊召唤的怪兽数量和对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果3的处理函数，将选中的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果3的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍存在于连锁中且未被王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽特殊召唤至场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
