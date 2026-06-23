--霊神統一
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「灵神的圣殿」不会被效果破坏，不会成为对方的效果的对象。
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。原本属性和解放的怪兽不同的1只「元素灵剑士」怪兽从卡组特殊召唤。
-- ③：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。手卡全部丢弃。那之后，从自己墓地选这个效果丢弃的卡数量的「灵神」怪兽加入手卡。
function c11167052.initial_effect(c)
	-- 在卡片关联列表中注册「灵神的圣殿」
	aux.AddCodeList(c,61557074)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，自己场上的「灵神的圣殿」不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c11167052.intg)
	-- 设置不成为效果对象的效果来源过滤函数（仅对方的效果）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 1回合1次，把自己场上1只怪兽解放才能发动。原本属性和解放的怪兽不同的1只「元素灵剑士」怪兽从卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11167052,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c11167052.spcost)
	e4:SetTarget(c11167052.sptg)
	e4:SetOperation(c11167052.spop)
	c:RegisterEffect(e4)
	-- 把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。手卡全部丢弃。那之后，从自己墓地选这个效果丢弃的卡数量的「灵神」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11167052,1))  --"墓地回收"
	e5:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c11167052.thcon)
	e5:SetCost(c11167052.thcost)
	e5:SetTarget(c11167052.thtg)
	e5:SetOperation(c11167052.thop)
	c:RegisterEffect(e5)
end
-- 检查是否为自己场上表侧表示的「灵神的圣殿」的过滤函数
function c11167052.intg(e,c)
	return c:IsFaceup() and c:IsCode(61557074)
end
-- 特殊召唤效果的代价前置检测，设置标志值为100
function c11167052.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 检查自己场上可解放怪兽的过滤函数（解放后需腾出空位且卡组存在原本属性不同的「元素灵剑士」）
function c11167052.filter1(c,e,tp)
	-- 检查卡组中是否存在与该解放怪兽原本属性不同且能够特殊召唤的「元素灵剑士」怪兽
	return Duel.IsExistingMatchingCard(c11167052.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute())
		-- 检查将该怪兽解放后是否能在自己场上提供至少一个可用于特殊召唤的怪兽区域空位
		and Duel.GetMZoneCount(tp,c)>0
end
-- 用于特殊召唤的「元素灵剑士」怪兽的过滤函数（原本属性与被解放怪兽不同，且可以特殊召唤）
function c11167052.filter2(c,e,tp,att)
	return c:IsSetCard(0x400d) and c:GetOriginalAttribute()~=att and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标确认（检查并选择1只场上的怪兽解放作为代价，记录其原本属性，并设置特殊召唤操作信息）
function c11167052.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在可用于该效果解放的怪兽
		return Duel.CheckReleaseGroup(tp,c11167052.filter1,1,nil,e,tp)
	end
	-- 让玩家选择1张符合条件的怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,c11167052.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetOriginalAttribute())
	-- 将选中的怪兽解放作为效果发动的代价
	Duel.Release(rg,REASON_COST)
	-- 设置效果处理时的操作信息，标记从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行处理逻辑（从卡组中选择1只原本属性与被解放怪兽不同的「元素灵剑士」特殊召唤）
function c11167052.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域空格，若没有则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local att=e:GetLabel()
	-- 给玩家显示选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只原本属性与被解放怪兽不同的「元素灵剑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c11167052.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,att)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示在自己场上特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查该卡当前是否在场上已经处于表侧表示生效状态以作为发动条件
function c11167052.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 墓地回收效果的代价处理（检查并把魔法与陷阱区域表侧表示的这张卡送去墓地）
function c11167052.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将场上表侧表示的这张卡送去墓地作为发动效果的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 用于从墓地加入手牌的「灵神」怪兽的过滤函数
function c11167052.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x113) and c:IsAbleToHand()
end
-- 墓地回收效果的发动准备与目标确认（检查手卡数量并确认墓地是否存在对应数量的「灵神」怪兽，设置丢弃手卡和将墓地的卡加入手卡的操作信息）
function c11167052.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡的所有卡片
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=hg:GetCount()
	-- 检查自己手卡数量是否大于0，且墓地中是否存在不少于该手卡数量的「灵神」怪兽
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(c11167052.thfilter,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 设置效果处理时的操作信息，标记丢弃所有的自己手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,hg,ct,0,0)
	-- 设置效果处理时的操作信息，标记从墓地将对应丢弃卡片数量的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_GRAVE)
end
-- 墓地回收效果的处理逻辑（丢弃所有自己手卡，然后从自己墓地选择与丢弃卡片数量相同的「灵神」怪兽加入手卡）
function c11167052.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡的所有卡片
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 把所有手卡作为效果处理丢弃并送去墓地，并记录实际送去墓地的卡片数量
	local ct=Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
	if ct<=0 then return end
	-- 给玩家显示选择将墓地卡片加入手卡的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地中选择与丢弃卡片数量相同的「灵神」怪兽
	local g=Duel.SelectMatchingCard(tp,c11167052.thfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使前后效果视为不同时处理
		Duel.BreakEffect()
		-- 将选中的「灵神」怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
