--召喚神エクゾディア
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「被封印」怪兽解放的场合才能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的「被封印」怪兽数量×1000。
-- ②：场上的这张卡不受其他卡的效果影响。
-- ③：自己结束阶段发动。从自己墓地把1只「被封印」怪兽加入手卡。
-- ④：这张卡被战斗破坏送去墓地时才能发动。手卡的「被封印」怪兽任意数量给对方观看，自己抽出给人观看的数量。
function c58604027.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上1只「被封印」怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c58604027.spcon)
	e2:SetTarget(c58604027.sptg)
	e2:SetOperation(c58604027.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己墓地的「被封印」怪兽数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c58604027.atkval)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡不受其他卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c58604027.efilter)
	c:RegisterEffect(e4)
	-- ③：自己结束阶段发动。从自己墓地把1只「被封印」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(58604027,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(c58604027.thcon)
	e5:SetTarget(c58604027.thtg)
	e5:SetOperation(c58604027.thop)
	c:RegisterEffect(e5)
	-- ④：这张卡被战斗破坏送去墓地时才能发动。手卡的「被封印」怪兽任意数量给对方观看，自己抽出给人观看的数量。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(58604027,1))
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DESTROYED)
	e6:SetCondition(c58604027.drcon)
	e6:SetTarget(c58604027.drtg)
	e6:SetOperation(c58604027.drop)
	c:RegisterEffect(e6)
end
-- 过滤函数：过滤自己墓地中的「被封印」怪兽
function c58604027.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x40)
end
-- 攻击力数值计算函数：计算自己墓地中「被封印」怪兽的数量并乘以1000
function c58604027.atkval(e,c)
	-- 获取自己墓地中满足条件的「被封印」怪兽数量，并乘以1000作为攻击力上升值
	return Duel.GetMatchingGroupCount(c58604027.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*1000
end
-- 特殊召唤条件过滤函数：过滤场上可解放的「被封印」怪兽，且解放后需有可用的怪兽区域
function c58604027.spfilter(c,tp)
	return c:IsSetCard(0x40)
		-- 检查该卡解放后是否能空出可用的怪兽区域，且该卡必须在自己场上或者是场上表侧表示存在
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件检查函数：检查场上是否存在至少1只可解放的「被封印」怪兽
function c58604027.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足特殊召唤解放条件的卡
	return Duel.CheckReleaseGroupEx(tp,c58604027.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数：让玩家选择1只场上的「被封印」怪兽作为解放对象
function c58604027.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的卡片组，并过滤出满足特殊召唤条件的「被封印」怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c58604027.spfilter,nil,tp)
	-- 向玩家提示选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数：解放选中的怪兽以进行特殊召唤
function c58604027.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽组，原因为特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 免疫效果过滤函数：使自身不受除自身以外的卡片效果影响
function c58604027.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 回收效果的发动条件检查函数：必须在自己的回合
function c58604027.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 回收效果的过滤函数：过滤自己墓地中可以加入手牌的「被封印」怪兽
function c58604027.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x40) and c:IsAbleToHand()
end
-- 回收效果的发动准备函数：设置将墓地卡片加入手牌的操作信息
function c58604027.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从自己墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 回收效果的执行函数：选择自己墓地1只「被封印」怪兽加入手牌并给对方确认
function c58604027.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的「被封印」怪兽卡
	local g=Duel.SelectMatchingCard(tp,c58604027.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 抽卡效果的发动条件检查函数：自身被战斗破坏送去墓地时
function c58604027.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 展示卡片的过滤函数：过滤手牌中未公开的「被封印」怪兽
function c58604027.cfilter(c)
	return c:IsSetCard(0x40) and not c:IsPublic()
end
-- 抽卡效果的发动准备函数：检查玩家是否能抽卡以及手牌中是否有可展示的卡，并设置抽卡操作信息
function c58604027.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家当前是否可以抽至少1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且检查手牌中是否存在至少1张满足条件的「被封印」怪兽卡
		and Duel.IsExistingMatchingCard(c58604027.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：玩家抽卡，数量在效果处理时确定
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数：让玩家选择手牌中任意数量的「被封印」怪兽给对方观看，并抽出相同数量的卡
function c58604027.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的卡片数量，作为可展示卡片数量的上限
	local dt=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dt==0 then return end
	-- 向玩家提示选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌中选择1到卡组剩余数量张满足条件的「被封印」怪兽卡
	local cg=Duel.SelectMatchingCard(tp,c58604027.cfilter,tp,LOCATION_HAND,0,1,dt,nil)
	-- 将选中的手牌给对方玩家确认
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
	local ct=cg:GetCount()
	-- 让玩家因效果抽与展示卡片数量相同的卡
	Duel.Draw(tp,ct,REASON_EFFECT)
end
