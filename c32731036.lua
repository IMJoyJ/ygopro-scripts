--深淵の獣ルベリオン
-- 效果：
-- 这张卡不能通常召唤。「深渊之兽 赫界龙」1回合1次在把自己场上1只6星以上的龙族·暗属性怪兽解放的场合才能从手卡·墓地特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从卡组把「深渊之兽 赫界龙」以外的1只「深渊之兽」怪兽加入手卡。
-- ②：自己主要阶段才能发动。从卡组把1张「烙印」永续魔法·永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 为「深渊之兽 赫界龙」注册全部效果：启用苏生限制；添加不可无效/复制的特殊召唤条件限制（不能通常召唤）；注册从手卡·墓地解放1只6星以上暗属性龙族怪兽进行的规则特殊召唤；注册①检索「深渊之兽」怪兽的手卡发动效果；注册②从卡组放置「烙印」永续魔陷的场上发动效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：“这张卡不能通常召唤。”
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- 对应效果原文：“「深渊之兽 赫界龙」1回合1次在把自己场上1只6星以上的龙族·暗属性怪兽解放的场合才能从手卡·墓地特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：“①：把这张卡从手卡送去墓地才能发动。从卡组把「深渊之兽 赫界龙」以外的1只「深渊之兽」怪兽加入手卡。”
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 对应效果原文：“②：自己主要阶段才能发动。从卡组把1张「烙印」永续魔法·永续陷阱卡在自己场上表侧表示放置。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否为6星以上、暗属性、龙族，且将其作为特殊召唤解放后自己场上仍有可用的怪兽区空格（因为特殊召唤需要空位）。
function s.cfilter(c,tp)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
		-- 额外检查：解放该候选怪兽后，自己场上存在可用的怪兽区空格，保证后续规则特殊召唤能够成功。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 规则特殊召唤的发动条件：若c为nil则返回true用于规则询问；否则确认当前玩家场上存在至少1只满足cfilter的可解放怪兽（用于特殊召唤手续中的解放）。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家是否存在至少1只满足cfilter条件的可解放怪兽（解放原因设定为特殊召唤REASON_SPSUMMON）。
	return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 规则特殊召唤手续中的选择部分：获取所有可解放怪兽并过滤出满足条件的卡，弹出“请选择要解放的卡”提示，让玩家选择1只（可取消），选中后暂存在效果的LabelObject中供后续解放使用。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的怪兽组（不包含手卡），并过滤出满足cfilter条件的候选解放素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.cfilter,nil,tp)
	-- 弹出选择提示，提示文字为“请选择要解放的卡”，用于让玩家选择特殊召唤要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则特殊召唤的处理：取出之前保存的被选中怪兽，将其解放，完成特殊召唤手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将被选中的怪兽解放（reason为REASON_SPSUMMON，作为特殊召唤手续的一部分）。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果的发动代价：从手卡把这张卡送去墓地；chk==0时只检查能否送去墓地作为代价，满足后实际送入墓地。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为发动①效果的代价（REASON_COST）。
	Duel.SendtoGrave(c,REASON_COST)
end
-- ①效果检索的过滤条件：必须是怪兽、属于「深渊之兽」系列（0x188）、可以加入手卡，且不能是本卡「深渊之兽 赫界龙」（id）。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x188) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ①效果的发动条件和操作信息：chk==0时检查卡组是否存在1张符合条件的「深渊之兽」怪兽；并设置本次操作类别为检索并加入手卡，预设在效果处理时从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足s.filter的「深渊之兽」怪兽（本卡除外）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时会把1张卡从卡组加入手卡（目标暂不固定，数量1，位置卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：弹出“请选择要加入手牌的卡”提示，从卡组选择1张符合条件的「深渊之兽」怪兽加入手卡，并向对方确认选择的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足s.filter的「深渊之兽」怪兽（本卡除外）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡（nil表示加入持有者手卡），原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡，使其确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果可放置的卡的条件：必须是永续魔法或永续陷阱卡、属于「烙印」系列（0x15d）、不是禁止卡，并且场上不存在同名卡（CheckUniqueOnField），才能表侧放置。
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x15d)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ②效果的发动条件：chk==0时，要求自己魔法陷阱区有空位，且卡组存在至少1张满足pfilter的「烙印」永续魔陷。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法陷阱区是否有可用的区域来放置新的魔法陷阱。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组是否存在至少1张满足pfilter的「烙印」永续魔法·永续陷阱。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ②效果处理：若魔法陷阱区仍有空位，弹出“请选择要放置到场上的卡”提示，从卡组选择1张符合条件的「烙印」永续魔陷，以表侧表示放置到自己魔法陷阱区。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查魔法陷阱区是否有空位，若无空位则效果处理不适用（中止）。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 弹出选择提示，提示文字为“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张满足pfilter的「烙印」永续魔法/永续陷阱，并取得第一张（因为只选1张）。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 将选择的卡以表侧表示放置到自己的魔法陷阱区（enable=true表示放置后立即适用其效果）。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
