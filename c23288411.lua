--冥骸合竜－メメントラル・テクトリカ
-- 效果：
-- 这张卡不能通常召唤。让这张卡以外的自己的手卡·墓地的「莫忘」怪兽5种类各1只回到卡组·额外卡组的场合才能从手卡·墓地特殊召唤。
-- ①：自己场上没有其他怪兽存在的场合，这张卡可以向对方怪兽全部各作1次攻击。
-- ②：1回合1次，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的手卡·墓地把1只「莫忘」怪兽特殊召唤。
local s,id,o=GetID()
-- 在卡片上注册所有效果：启用苏生限制（不能通常召唤）、特殊召唤规则（从手卡·墓地将5种类莫忘怪兽回到卡组/额外卡组才能特召）、①可向对方全部怪兽各攻击1次、②对方发动效果时从手卡·墓地特召1只莫忘怪兽。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 让这张卡以外的自己的手卡·墓地的「莫忘」怪兽5种类各1只回到卡组·额外卡组的场合才能从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.spscon)
	e2:SetTarget(s.spstg)
	e2:SetOperation(s.spsop)
	c:RegisterEffect(e2)
	-- ①：自己场上没有其他怪兽存在的场合，这张卡可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetCondition(s.acon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：1回合1次，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的手卡·墓地把1只「莫忘」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 定义素材过滤函数：筛选卡名含「莫忘」的怪兽，且可以作为代价返回卡组或额外卡组。
function s.cfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- 特殊召唤手续的条件：检查自己手卡·墓地中能否选出5张卡名互不相同的「莫忘」怪兽，且自己主要怪兽区有空位。
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己手卡·墓地中满足s.cfilter的「莫忘」怪兽（排除这张卡自身）。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 如果自己主要怪兽区没有空位，则无法满足特殊召唤条件。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 设置额外检查函数为卡名互不相同，确保组成的5张素材卡名各异。
	aux.GCheckAdditional=aux.dncheck
	-- 检查卡组中是否存在恰好5张满足条件且卡名互不相同的「莫忘」怪兽组合。
	local res=g:CheckSubGroup(aux.TRUE,5,5)
	-- 清除额外检查函数，避免影响后续其他选择。
	aux.GCheckAdditional=nil
	return res
end
-- 特殊召唤手续的选择阶段：让玩家从手卡·墓地选出5张卡名互不相同的「莫忘」怪兽作为返回卡组的素材，并保存到效果标签。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡·墓地中可作为特殊召唤素材的「莫忘」怪兽（排除自身）。
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 弹出选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置额外检查函数为卡名互不相同，保证所选素材卡名各异。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从素材组中必须选择恰好5张卡名互不相同的「莫忘」怪兽。
	local sg=mg:SelectSubGroup(tp,aux.TRUE,true,5,5)
	-- 清除额外检查函数，避免影响后续操作。
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤手续：展示选中的手卡素材、播放墓地素材的选择动画，然后将这些素材返回持有者卡组并洗切。
function s.spsop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg>0 then
		-- 将选择的手卡素材展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,hg)
	end
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gg>0 then
		-- 为选择的墓地素材播放选中动画，让双方确认这些卡被选为素材。
		Duel.HintSelection(gg)
	end
	-- 将这些素材卡送去持有者卡组并洗牌，原因为特殊召唤。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的攻击全体条件：自己场上没有其他怪兽存在（即场上只有这张卡）。
function s.acon(e)
	local tp=e:GetHandlerPlayer()
	-- 判定自己主要怪兽区的卡数是否为1，即仅存在这张卡自身。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- ②效果的触发条件：对方发动了魔法·陷阱·怪兽的效果（即连锁的发动者rp为对方）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 特殊召唤对象的过滤条件：卡名含「莫忘」的怪兽，且可被特殊召唤（满足苏生限制和召唤条件）。
function s.filter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的合法性检查：自己主要怪兽区有空位，且手卡·墓地中存在可特殊召唤的「莫忘」怪兽，并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在至少1只满足s.filter条件的「莫忘」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，声明本效果含有特殊召唤，特召对象来自手卡·墓地，预计数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 处理②效果：在主要怪兽区有空位时，从手卡·墓地选择1只「莫忘」怪兽表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只满足条件且不受王家长眠之谷影响的「莫忘」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
