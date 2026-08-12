--Evil★Twins キスキル・リィラ
-- 效果：
-- 这张卡不能通常召唤。把自己场上2只连接怪兽解放的场合才能从手卡·墓地特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方在自身场上的卡是3张以上的场合直到变成2张为止必须送去墓地。
-- ②：只要自己墓地有「姬丝基勒」怪兽以及「璃拉」怪兽存在，这张卡的攻击力·守备力上升2200。
function c62098216.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 把自己场上2只连接怪兽解放的场合才能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c62098216.sprcon)
	e1:SetTarget(c62098216.sprtg)
	e1:SetOperation(c62098216.sprop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合才能发动。对方在自身场上的卡是3张以上的场合直到变成2张为止必须送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62098216,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,62098216)
	e2:SetTarget(c62098216.tgtg)
	e2:SetOperation(c62098216.tgop)
	c:RegisterEffect(e2)
	-- ②：只要自己墓地有「姬丝基勒」怪兽以及「璃拉」怪兽存在，这张卡的攻击力·守备力上升2200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c62098216.con)
	e3:SetValue(2200)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件检查函数：检查自己场上是否存在可以解放的2只连接怪兽，且解放后有足够的怪兽区域
function c62098216.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上可用于特殊召唤解放的连接怪兽卡组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsType,nil,TYPE_LINK)
	-- 检查是否能选出2只满足解放后主怪兽区有空位条件的连接怪兽
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的选择目标函数：让玩家选择2只用于解放的连接怪兽，并将其保存在效果标签中
function c62098216.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可用于特殊召唤解放的连接怪兽卡组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(Card.IsType,nil,TYPE_LINK)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择2只满足解放后主怪兽区有空位条件的连接怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数：解放选中的怪兽以完成特殊召唤
function c62098216.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动准备（Target）：检查对方场上卡片数量是否在3张以上，且对方是否能将卡送去墓地，并设置送去墓地的操作信息
function c62098216.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=g:GetCount()-2
	-- 检查对方是否能将卡送去墓地、对方场上卡片数量是否大于2张，且存在可以送去墓地的卡
	if chk==0 then return Duel.IsPlayerCanSendtoGrave(1-tp) and ct>0 and g:IsExists(Card.IsAbleToGrave,1,nil,1-tp,nil) end
	-- 设置效果处理信息：对方场上的卡送去墓地，数量为对方场上卡片数减去2
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,ct,0,0)
end
-- ①效果的执行（Operation）：对方选择自身场上的卡直到剩下2张为止，并送去墓地
function c62098216.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果对方不能将卡送去墓地，则效果不处理
	if not Duel.IsPlayerCanSendtoGrave(1-tp) then return end
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=g:GetCount()-2
	if ct>0 then
		-- 提示对方玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:FilterSelect(1-tp,Card.IsAbleToGrave,ct,ct,nil,1-tp,nil)
		-- 对方将选中的卡因规则送去墓地（不视为效果送去墓地）
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
-- 过滤条件：检查卡片是否属于指定系列
function c62098216.cfilter(c,setcode)
	return c:IsFaceup() and c:IsSetCard(setcode)
end
-- ②效果的适用条件：检查自己墓地是否存在「姬丝基勒」怪兽以及「璃拉」怪兽
function c62098216.con(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己墓地是否存在「姬丝基勒」怪兽（系列号0x152）
	return Duel.IsExistingMatchingCard(c62098216.cfilter,tp,LOCATION_GRAVE,0,1,nil,0x152)
		-- 检查自己墓地是否存在「璃拉」怪兽（系列号0x153）
		and Duel.IsExistingMatchingCard(c62098216.cfilter,tp,LOCATION_GRAVE,0,1,nil,0x153)
end
