--冥骸合竜－メメントラル・テクトリカ
-- 效果：
-- 这张卡不能通常召唤。让这张卡以外的自己的手卡·墓地的「莫忘」怪兽5种类各1只回到卡组·额外卡组的场合才能从手卡·墓地特殊召唤。
-- ①：自己场上没有其他怪兽存在的场合，这张卡可以向对方怪兽全部各作1次攻击。
-- ②：1回合1次，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的手卡·墓地把1只「莫忘」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置特殊召唤条件、特殊召唤程序、攻击全部和连锁触发效果
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
	-- 自己场上没有其他怪兽存在的场合，这张卡可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetCondition(s.acon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 1回合1次，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。从自己的手卡·墓地把1只「莫忘」怪兽特殊召唤。
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
-- 过滤条件：卡为「莫忘」怪兽且可送入卡组或额外卡组作为费用
function s.cfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- 检查是否满足特殊召唤条件：手牌和墓地的「莫忘」怪兽中是否存在5种不同种类的怪兽各1只
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取手牌和墓地中的所有「莫忘」怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 若场上没有空位则不能特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 检查是否存在5种不同种类的怪兽各1只
	local res=g:CheckSubGroup(aux.TRUE,5,5)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	return res
end
-- 设置特殊召唤目标：选择5种不同种类的「莫忘」怪兽送回卡组
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌和墓地中的所有「莫忘」怪兽
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 选择5种不同种类的「莫忘」怪兽
	local sg=mg:SelectSubGroup(tp,aux.TRUE,true,5,5)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作：将选中的卡送回卡组并确认手牌
function s.spsop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg>0 then
		-- 确认对方查看手牌中的卡
		Duel.ConfirmCards(1-tp,hg)
	end
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gg>0 then
		-- 显示墓地中的卡被选为对象
		Duel.HintSelection(gg)
	end
	-- 将选中的卡送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否满足攻击全部的条件：自己场上只有1只怪兽
function s.acon(e)
	local tp=e:GetHandlerPlayer()
	-- 自己场上只有1只怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 判断是否满足特殊召唤条件：对方发动效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤条件：卡为「莫忘」怪兽且可特殊召唤
function s.filter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤目标：检查是否有可特殊召唤的「莫忘」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有「莫忘」怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 执行特殊召唤操作：选择并特殊召唤1只「莫忘」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则不能特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只可特殊召唤的「莫忘」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
