--Shamanite Shamanknight
-- 效果：
-- 3星怪兽×2只以上
-- 这张卡超量召唤的场合，或者自己的陷阱卡被除外的场合：可以以除外状态的自己的1张陷阱卡为对象；那张卡作为这张卡的超量素材。
-- 可以把这张卡的超量素材任意数量取除，以自己墓地·除外状态的持有取除数量相同等级的1只暗属性怪兽为对象；那只怪兽特殊召唤。
-- 「方解黑骑士」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果：注册超量召唤手续与苏生限制，并注册三个效果——e1为这张卡超量召唤成功时获取超量素材的诱发取对象效果（1回合1次），e2为自己的陷阱卡被除外时获取超量素材的诱发取对象效果，e3为取除超量素材特殊召唤暗属性怪兽的起动效果（1回合1次）
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可以用2只以上（最多99只）等级3的怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 这张卡超量召唤的场合：可以以除外状态的自己的1张陷阱卡为对象；那张卡作为这张卡的超量素材。「方解黑骑士」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取超量素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,0))  --"获取超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(s.xyzcon2)
	c:RegisterEffect(e2)
	-- 可以把这张卡的超量素材任意数量取除，以自己墓地·除外状态的持有取除数量相同等级的1只暗属性怪兽为对象；那只怪兽特殊召唤。「方解黑骑士」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
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
-- 效果发动条件：这张卡是超量召唤成功的场合才能发动
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤条件：卡是表侧表示的陷阱卡且控制者是自己（用于检测被除外的自己的陷阱卡）
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsControler(tp)
end
-- 效果发动条件：被除外的卡中存在自己的陷阱卡
function s.xyzcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 对象过滤条件：卡是表侧表示的陷阱卡且可以作为超量素材叠放
function s.filter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsCanOverlay()
end
-- 取对象阶段：连锁对象需是除外的自己的可作为超量素材的陷阱卡；发动条件检测要求这张卡是超量怪兽且除外状态存在可作为对象的陷阱卡
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检测自己除外状态是否存在1张以上可作为对象的表侧表示陷阱卡
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 以自己除外状态的1张满足条件的陷阱卡为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler())
end
-- 效果处理：若这张卡和对象卡都仍与连锁关联且对象不受此效果影响，则将对象卡作为这张卡的超量素材
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 把对象卡作为这张卡的超量素材叠放
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 发动代价处理：检索墓地·除外状态可特殊召唤的暗属性怪兽，统计能通过取除对应数量超量素材来特殊召唤的等级，让玩家宣言要取除的超量素材数量，取除该数量的超量素材作为代价并记录该数量
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索自己墓地·除外状态所有满足特殊召唤条件的暗属性怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local lvt={}
	local res=false
	-- 逐个遍历检索到的怪兽，检查其等级
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
	-- 提示玩家选择要取除的超量素材的数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要取除的超量素材的数量"
	-- 让玩家宣言要取除的超量素材数量（从可特殊召唤怪兽的等级中选择）
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveOverlayCard(tp,lv,lv,REASON_COST)
	e:SetLabel(lv)
end
-- 对象过滤条件：卡是表侧表示的暗属性怪兽、可以特殊召唤，且等级与宣言的取除数量相同
function s.spfilter(c,e,tp,lv)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not lv or c:IsLevel(lv))
end
-- 取对象阶段：连锁对象需是自己墓地·除外状态的满足条件的暗属性怪兽；发动条件检测要求自己主要怪兽区有空位且存在可作为对象的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp,e:GetLabel()) end
	-- 发动条件检测：自己主要怪兽区存在可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己墓地·除外状态是否存在1只以上可作为对象的满足条件的暗属性怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地·除外状态的1只等级与取除数量相同的暗属性怪兽为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,e:GetLabel())
	-- 设置操作信息：本连锁将特殊召唤对象这1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象卡仍与连锁关联且不受王家长眠之谷影响，则将对象怪兽以表侧表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与连锁关联且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
