--ウェイクアップ・センチュリオン！
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的魔法与陷阱区域有表侧表示怪兽卡存在的场合，宣言4或8的等级才能发动。把持有宣言的等级的1只「百夫长骑士衍生物」（炎族·暗·攻/守0）在自己场上特殊召唤。这衍生物不能作为融合·连接素材。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把「觉醒吧百夫长骑士！」以外的1张「百夫长骑士」卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果：①发动时宣言等级特召衍生物，②墓地除外将卡组「百夫长骑士」卡送墓。
function s.initial_effect(c)
	-- ①：自己的魔法与陷阱区域有表侧表示怪兽卡存在的场合，宣言4或8的等级才能发动。把持有宣言的等级的1只「百夫长骑士衍生物」（炎族·暗·攻/守0）在自己场上特殊召唤。这衍生物不能作为融合·连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把「觉醒吧百夫长骑士！」以外的1张「百夫长骑士」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为发动效果的cost。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本是怪兽卡且在场上表侧表示存在的卡。
function s.cfilter(c)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsFaceup()
end
-- ①效果的发动条件：自己的魔法与陷阱区域有表侧表示怪兽卡存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域是否存在至少1张表侧表示的怪兽卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil)
end
-- ①效果的靶向/发动准备：检查怪兽区域空位，并判定是否能特殊召唤4星或8星的衍生物。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能特殊召唤4星的「百夫长骑士衍生物」。
	local t1=Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1a2,TYPES_TOKEN_MONSTER,0,0,4,RACE_PYRO,ATTRIBUTE_DARK)
	-- 检查玩家是否能特殊召唤8星的「百夫长骑士衍生物」。
	local t2=Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1a2,TYPES_TOKEN_MONSTER,0,0,8,RACE_PYRO,ATTRIBUTE_DARK)
	-- 检查怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		(t1 or t2) end
	local lv=0
	if t1 and t2 then
		-- 提示玩家宣言一个等级。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请宣言1个等级"
		-- 让玩家宣言4或8的等级，并将宣言的值保存到效果标签中。
		e:SetLabel(Duel.AnnounceLevel(tp,4,8,5,6,7))
	elseif t1 then
		-- 提示玩家宣言一个等级。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请宣言1个等级"
		-- 只能特殊召唤4星时，强制玩家宣言等级4并保存。
		e:SetLabel(Duel.AnnounceLevel(tp,4,4))
	elseif t2 then
		-- 提示玩家宣言一个等级。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请宣言1个等级"
		-- 只能特殊召唤8星时，强制玩家宣言等级8并保存。
		e:SetLabel(Duel.AnnounceLevel(tp,8,8))
	end
	-- 设置连锁处理信息：产生1张衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理信息：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ①效果的效果处理：在场上特殊召唤宣言等级的「百夫长骑士衍生物」，并赋予其不能作为融合·连接素材的限制。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检查怪兽区域是否已无空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否无法特殊召唤对应等级的衍生物，若无法则不处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0x1a2,TYPES_TOKEN_MONSTER,0,0,lv,RACE_PYRO,ATTRIBUTE_DARK) then return end
	-- 在系统后台创建「百夫长骑士衍生物」卡片。
	local token=Duel.CreateToken(tp,id+o)
	-- 把持有宣言的等级的1只「百夫长骑士衍生物」（炎族·暗·攻/守0）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	e1:SetValue(lv)
	token:RegisterEffect(e1,true)
	-- 将衍生物以表侧表示特殊召唤到场上（分步处理）。
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能作为融合·连接素材。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetValue(1)
	token:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	token:RegisterEffect(e5)
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
end
-- 过滤条件：卡组中「觉醒吧百夫长骑士！」以外的「百夫长骑士」卡。
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1a2) and c:IsAbleToGrave()
end
-- ②效果的靶向/发动准备：检查卡组中是否存在可送去墓地的「百夫长骑士」卡，并设置送墓的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「百夫长骑士」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：将卡组的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1张「百夫长骑士」卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「百夫长骑士」卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
